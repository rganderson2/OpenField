import Foundation

/// Process-local `EventStore` for scaffolding, previews, and unit tests.
/// Not durable and not a network API.
public actor InMemoryEventStore: EventStore {
    private var events: [UUID: RallyEvent] = [:]
    private var eventsByJoinCode: [String: UUID] = [:]
    private var memberships: [UUID: Membership] = [:]
    private var teams: [UUID: Team] = [:]
    private var markers: [UUID: MapMarkerItem] = [:]
    private var messages: [UUID: ChatMessage] = [:]
    private var pingsByUserKey: [String: LocationPing] = [:]

    public init() {}

    // MARK: Events

    public func createEvent(_ event: RallyEvent) async throws -> RallyEvent {
        let code = event.joinCode.uppercased()
        if eventsByJoinCode[code] != nil {
            throw EventStoreError.conflict("Join code “\(code)” is already in use.")
        }
        var stored = event
        stored.joinCode = code
        stored.updatedAt = Date()
        events[stored.id] = stored
        eventsByJoinCode[code] = stored.id

        let hostMembership = Membership(
            eventId: stored.id,
            userId: stored.hostUserId,
            isHost: true
        )
        memberships[hostMembership.id] = hostMembership
        return stored
    }

    public func event(id: UUID) async throws -> RallyEvent {
        guard let event = events[id] else {
            throw EventStoreError.eventNotFound(id)
        }
        return event
    }

    public func event(joinCode: String) async throws -> RallyEvent {
        let code = joinCode.uppercased()
        guard let id = eventsByJoinCode[code], let event = events[id] else {
            throw EventStoreError.joinCodeNotFound(code)
        }
        return event
    }

    public func updateEvent(_ event: RallyEvent) async throws -> RallyEvent {
        guard events[event.id] != nil else {
            throw EventStoreError.eventNotFound(event.id)
        }
        var stored = event
        stored.updatedAt = Date()
        events[stored.id] = stored
        eventsByJoinCode[stored.joinCode.uppercased()] = stored.id
        return stored
    }

    public func setEventStatus(eventId: UUID, status: EventStatus) async throws -> RallyEvent {
        guard var event = events[eventId] else {
            throw EventStoreError.eventNotFound(eventId)
        }
        event.status = status
        event.updatedAt = Date()
        events[eventId] = event
        return event
    }

    public func deleteEvent(id: UUID) async throws {
        guard let event = events.removeValue(forKey: id) else {
            throw EventStoreError.eventNotFound(id)
        }
        eventsByJoinCode.removeValue(forKey: event.joinCode.uppercased())
        memberships = memberships.filter { $0.value.eventId != id }
        teams = teams.filter { $0.value.eventId != id }
        markers = markers.filter { $0.value.eventId != id }
        messages = messages.filter { $0.value.eventId != id }
        pingsByUserKey = pingsByUserKey.filter { !$0.key.hasPrefix(id.uuidString) }
    }

    // MARK: Membership

    public func joinEvent(eventId: UUID, userId: UUID, displayName: String) async throws -> Membership {
        _ = displayName // Reserved for profile upsert when profiles are stored remotely.
        guard events[eventId] != nil else {
            throw EventStoreError.eventNotFound(eventId)
        }
        if let existing = memberships.values.first(where: { $0.eventId == eventId && $0.userId == userId }) {
            return existing
        }
        let membership = Membership(eventId: eventId, userId: userId, isHost: false)
        memberships[membership.id] = membership
        return membership
    }

    public func leaveEvent(eventId: UUID, userId: UUID) async throws {
        guard let membership = memberships.values.first(where: { $0.eventId == eventId && $0.userId == userId }) else {
            throw EventStoreError.membershipNotFound
        }
        if membership.isHost {
            throw EventStoreError.conflict("Host cannot leave; end or delete the event instead.")
        }
        memberships.removeValue(forKey: membership.id)
        pingsByUserKey.removeValue(forKey: pingKey(eventId: eventId, userId: userId))

        // Detach from team roster if present.
        if let teamId = membership.teamId, var team = teams[teamId] {
            team.memberUserIds.removeAll { $0 == userId }
            teams[teamId] = team
        }
    }

    public func memberships(eventId: UUID) async throws -> [Membership] {
        guard events[eventId] != nil else {
            throw EventStoreError.eventNotFound(eventId)
        }
        return memberships.values.filter { $0.eventId == eventId }
    }

    public func membership(eventId: UUID, userId: UUID) async throws -> Membership {
        guard let membership = memberships.values.first(where: { $0.eventId == eventId && $0.userId == userId }) else {
            throw EventStoreError.membershipNotFound
        }
        return membership
    }

    // MARK: Teams

    public func upsertTeam(_ team: Team) async throws -> Team {
        guard events[team.eventId] != nil else {
            throw EventStoreError.eventNotFound(team.eventId)
        }
        teams[team.id] = team
        return team
    }

    public func teams(eventId: UUID) async throws -> [Team] {
        guard events[eventId] != nil else {
            throw EventStoreError.eventNotFound(eventId)
        }
        return teams.values.filter { $0.eventId == eventId }
    }

    public func assignMember(eventId: UUID, userId: UUID, teamId: UUID?) async throws -> Membership {
        guard var membership = memberships.values.first(where: { $0.eventId == eventId && $0.userId == userId }) else {
            throw EventStoreError.membershipNotFound
        }

        if let previousTeamId = membership.teamId, var previous = teams[previousTeamId] {
            previous.memberUserIds.removeAll { $0 == userId }
            teams[previousTeamId] = previous
        }

        if let teamId {
            guard var team = teams[teamId], team.eventId == eventId else {
                throw EventStoreError.teamNotFound(teamId)
            }
            if !team.memberUserIds.contains(userId) {
                team.memberUserIds.append(userId)
            }
            teams[teamId] = team
        }

        membership.teamId = teamId
        memberships[membership.id] = membership
        return membership
    }

    // MARK: Markers

    public func upsertMarker(_ marker: MapMarkerItem) async throws -> MapMarkerItem {
        guard events[marker.eventId] != nil else {
            throw EventStoreError.eventNotFound(marker.eventId)
        }
        markers[marker.id] = marker
        return marker
    }

    public func markers(eventId: UUID) async throws -> [MapMarkerItem] {
        guard events[eventId] != nil else {
            throw EventStoreError.eventNotFound(eventId)
        }
        return markers.values
            .filter { $0.eventId == eventId }
            .sorted { $0.order < $1.order }
    }

    public func deleteMarker(id: UUID) async throws {
        guard markers.removeValue(forKey: id) != nil else {
            throw EventStoreError.markerNotFound(id)
        }
    }

    // MARK: Chat

    public func postMessage(_ message: ChatMessage) async throws -> ChatMessage {
        guard events[message.eventId] != nil else {
            throw EventStoreError.eventNotFound(message.eventId)
        }
        messages[message.id] = message
        return message
    }

    public func messages(eventId: UUID) async throws -> [ChatMessage] {
        guard events[eventId] != nil else {
            throw EventStoreError.eventNotFound(eventId)
        }
        return messages.values
            .filter { $0.eventId == eventId }
            .sorted { $0.createdAt < $1.createdAt }
    }

    // MARK: Location pings

    public func upsertLocationPing(_ ping: LocationPing) async throws -> LocationPing {
        guard events[ping.eventId] != nil else {
            throw EventStoreError.eventNotFound(ping.eventId)
        }
        pingsByUserKey[pingKey(eventId: ping.eventId, userId: ping.userId)] = ping
        return ping
    }

    public func locationPings(eventId: UUID) async throws -> [LocationPing] {
        guard events[eventId] != nil else {
            throw EventStoreError.eventNotFound(eventId)
        }
        return pingsByUserKey.values.filter { $0.eventId == eventId }
    }

    // MARK: Helpers

    private func pingKey(eventId: UUID, userId: UUID) -> String {
        "\(eventId.uuidString):\(userId.uuidString)"
    }
}

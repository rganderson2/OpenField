import Foundation

/// Persistence and sync boundary for rally domain data.
/// Implementations may be in-memory (local), CloudKit, or another store.
public protocol EventStore: Sendable {
    // MARK: Events

    func createEvent(_ event: RallyEvent) async throws -> RallyEvent
    func event(id: UUID) async throws -> RallyEvent
    func event(joinCode: String) async throws -> RallyEvent
    func updateEvent(_ event: RallyEvent) async throws -> RallyEvent
    func setEventStatus(eventId: UUID, status: EventStatus) async throws -> RallyEvent
    func deleteEvent(id: UUID) async throws

    // MARK: Membership

    func joinEvent(eventId: UUID, userId: UUID, displayName: String) async throws -> Membership
    func leaveEvent(eventId: UUID, userId: UUID) async throws
    func memberships(eventId: UUID) async throws -> [Membership]
    func membership(eventId: UUID, userId: UUID) async throws -> Membership

    // MARK: Teams

    func upsertTeam(_ team: Team) async throws -> Team
    func teams(eventId: UUID) async throws -> [Team]
    func assignMember(eventId: UUID, userId: UUID, teamId: UUID?) async throws -> Membership

    // MARK: Markers

    func upsertMarker(_ marker: MapMarkerItem) async throws -> MapMarkerItem
    func markers(eventId: UUID) async throws -> [MapMarkerItem]
    func deleteMarker(id: UUID) async throws

    // MARK: Chat

    func postMessage(_ message: ChatMessage) async throws -> ChatMessage
    func messages(eventId: UUID) async throws -> [ChatMessage]

    // MARK: Location pings

    func upsertLocationPing(_ ping: LocationPing) async throws -> LocationPing
    func locationPings(eventId: UUID) async throws -> [LocationPing]
}

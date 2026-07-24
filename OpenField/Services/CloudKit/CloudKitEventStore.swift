import Foundation

/// Stub `EventStore` for the future CloudKit adapter.
/// Every method throws `EventStoreError.notImplemented` — no live container or network I/O.
public struct CloudKitEventStore: EventStore {
    public init() {}

    private func unsupported(_ name: String = #function) -> EventStoreError {
        .notImplemented("CloudKitEventStore.\(name)")
    }

    public func createEvent(_ event: RallyEvent) async throws -> RallyEvent {
        throw unsupported()
    }

    public func event(id: UUID) async throws -> RallyEvent {
        throw unsupported()
    }

    public func event(joinCode: String) async throws -> RallyEvent {
        throw unsupported()
    }

    public func updateEvent(_ event: RallyEvent) async throws -> RallyEvent {
        throw unsupported()
    }

    public func setEventStatus(eventId: UUID, status: EventStatus) async throws -> RallyEvent {
        throw unsupported()
    }

    public func deleteEvent(id: UUID) async throws {
        throw unsupported()
    }

    public func joinEvent(eventId: UUID, userId: UUID, displayName: String) async throws -> Membership {
        throw unsupported()
    }

    public func leaveEvent(eventId: UUID, userId: UUID) async throws {
        throw unsupported()
    }

    public func memberships(eventId: UUID) async throws -> [Membership] {
        throw unsupported()
    }

    public func membership(eventId: UUID, userId: UUID) async throws -> Membership {
        throw unsupported()
    }

    public func upsertTeam(_ team: Team) async throws -> Team {
        throw unsupported()
    }

    public func teams(eventId: UUID) async throws -> [Team] {
        throw unsupported()
    }

    public func assignMember(eventId: UUID, userId: UUID, teamId: UUID?) async throws -> Membership {
        throw unsupported()
    }

    public func upsertMarker(_ marker: MapMarkerItem) async throws -> MapMarkerItem {
        throw unsupported()
    }

    public func markers(eventId: UUID) async throws -> [MapMarkerItem] {
        throw unsupported()
    }

    public func deleteMarker(id: UUID) async throws {
        throw unsupported()
    }

    public func postMessage(_ message: ChatMessage) async throws -> ChatMessage {
        throw unsupported()
    }

    public func messages(eventId: UUID) async throws -> [ChatMessage] {
        throw unsupported()
    }

    public func upsertLocationPing(_ ping: LocationPing) async throws -> LocationPing {
        throw unsupported()
    }

    public func locationPings(eventId: UUID) async throws -> [LocationPing] {
        throw unsupported()
    }
}

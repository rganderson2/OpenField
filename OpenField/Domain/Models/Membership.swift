import Foundation

/// Links a user to an event, optionally to a team, and records host privilege.
public struct Membership: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var eventId: UUID
    public var userId: UUID
    public var teamId: UUID?
    public var isHost: Bool

    public init(
        id: UUID = UUID(),
        eventId: UUID,
        userId: UUID,
        teamId: UUID? = nil,
        isHost: Bool = false
    ) {
        self.id = id
        self.eventId = eventId
        self.userId = userId
        self.teamId = teamId
        self.isHost = isHost
    }
}

import Foundation

/// A teammate (or self) location sample shared within an event.
public struct LocationPing: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var eventId: UUID
    public var userId: UUID
    public var teamId: UUID?
    public var displayName: String
    public var latitude: Double
    public var longitude: Double
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        eventId: UUID,
        userId: UUID,
        teamId: UUID? = nil,
        displayName: String,
        latitude: Double,
        longitude: Double,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.eventId = eventId
        self.userId = userId
        self.teamId = teamId
        self.displayName = displayName
        self.latitude = latitude
        self.longitude = longitude
        self.updatedAt = updatedAt
    }
}

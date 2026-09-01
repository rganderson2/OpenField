import Foundation

/// Event-wide text chat message (model only; transport arrives later).
public struct ChatMessage: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var eventId: UUID
    public var senderId: UUID
    public var senderName: String
    public var body: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        eventId: UUID,
        senderId: UUID,
        senderName: String,
        body: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.eventId = eventId
        self.senderId = senderId
        self.senderName = senderName
        self.body = body
        self.createdAt = createdAt
    }
}

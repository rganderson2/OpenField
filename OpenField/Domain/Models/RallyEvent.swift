import Foundation

/// A host-created outdoor team event (scavenger hunt / checkpoint style).
public struct RallyEvent: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var title: String
    public var description: String
    public var rulesText: String
    public var status: EventStatus
    public var joinCode: String
    public var hostUserId: UUID
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        rulesText: String = "",
        status: EventStatus = .draft,
        joinCode: String,
        hostUserId: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.rulesText = rulesText
        self.status = status
        self.joinCode = joinCode
        self.hostUserId = hostUserId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

import Foundation

/// A named team competing within a rally event.
public struct Team: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var eventId: UUID
    public var name: String
    /// sRGB components in `0...1`. Kept as Doubles so domain stays MapKit-free.
    public var colorRed: Double
    public var colorGreen: Double
    public var colorBlue: Double
    public var memberUserIds: [UUID]

    public init(
        id: UUID = UUID(),
        eventId: UUID,
        name: String,
        colorRed: Double,
        colorGreen: Double,
        colorBlue: Double,
        memberUserIds: [UUID] = []
    ) {
        self.id = id
        self.eventId = eventId
        self.name = name
        self.colorRed = colorRed
        self.colorGreen = colorGreen
        self.colorBlue = colorBlue
        self.memberUserIds = memberUserIds
    }
}

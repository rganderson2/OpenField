import Foundation

public enum MapMarkerKind: String, Codable, Sendable, CaseIterable, Hashable {
    case objective
    case checkpoint
}

public enum MapMarkerStatus: String, Codable, Sendable, CaseIterable, Hashable {
    case open
    case done
}

/// An objective or checkpoint placed on the map for an event.
public struct MapMarkerItem: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var eventId: UUID
    public var kind: MapMarkerKind
    public var title: String
    public var detail: String
    public var latitude: Double
    public var longitude: Double
    public var status: MapMarkerStatus
    /// Display / completion order within the event (lower first).
    public var order: Int

    public init(
        id: UUID = UUID(),
        eventId: UUID,
        kind: MapMarkerKind,
        title: String,
        detail: String = "",
        latitude: Double,
        longitude: Double,
        status: MapMarkerStatus = .open,
        order: Int = 0
    ) {
        self.id = id
        self.eventId = eventId
        self.kind = kind
        self.title = title
        self.detail = detail
        self.latitude = latitude
        self.longitude = longitude
        self.status = status
        self.order = order
    }
}

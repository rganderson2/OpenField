import CoreLocation
import Foundation
import MapKit

/// MapKit / CoreLocation adapters for domain coordinates.
/// Keep MapKit imports here — domain models store Doubles only.

public extension MapMarkerItem {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Stable identity for MapKit annotations / selection.
    var annotationID: String {
        id.uuidString
    }

    init(eventId: UUID, kind: MapMarkerKind, title: String, detail: String = "", coordinate: CLLocationCoordinate2D, status: MapMarkerStatus = .open, order: Int = 0) {
        self.init(
            eventId: eventId,
            kind: kind,
            title: title,
            detail: detail,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            status: status,
            order: order
        )
    }
}

public extension LocationPing {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var annotationID: String {
        "ping:\(userId.uuidString)"
    }

    init(
        eventId: UUID,
        userId: UUID,
        teamId: UUID? = nil,
        displayName: String,
        coordinate: CLLocationCoordinate2D,
        updatedAt: Date = Date()
    ) {
        self.init(
            eventId: eventId,
            userId: userId,
            teamId: teamId,
            displayName: displayName,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            updatedAt: updatedAt
        )
    }
}

/// Lightweight annotation identity shared by future Map content.
public struct MapAnnotationIdentity: Hashable, Sendable {
    public let id: String
    public let coordinate: CLLocationCoordinate2D
    public let title: String
    public let subtitle: String?

    public init(id: String, coordinate: CLLocationCoordinate2D, title: String, subtitle: String? = nil) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }

    public init(marker: MapMarkerItem) {
        self.init(
            id: marker.annotationID,
            coordinate: marker.coordinate,
            title: marker.title,
            subtitle: marker.detail.isEmpty ? marker.kind.rawValue : marker.detail
        )
    }

    public init(ping: LocationPing) {
        self.init(
            id: ping.annotationID,
            coordinate: ping.coordinate,
            title: ping.displayName,
            subtitle: nil
        )
    }
}

extension CLLocationCoordinate2D: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

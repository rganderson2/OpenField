import Foundation

/// Throttle policy for publishing location pings.
/// Constants only — no timers or background work live here.
public enum LocationPingPolicy {
    /// Minimum movement (meters) before a new ping is warranted.
    public static let minimumDistanceMeters: CLLocationDistanceLike = 20

    /// Minimum time between pings when moving.
    public static let minimumInterval: TimeInterval = 10

    /// Maximum silence before a heartbeat ping even without movement.
    public static let heartbeatInterval: TimeInterval = 60
}

/// Local alias so Domain stays free of CoreLocation imports.
public typealias CLLocationDistanceLike = Double

import Foundation

/// Decision helper for location ping throttling (distance + time policy).
/// Kept free of CoreLocation so unit tests stay lightweight.
public enum LocationPingThrottle {
    /// Returns `candidate` when policy allows a new ping; otherwise `nil`.
    public static func pingIfNeeded(
        candidate: LocationPing,
        previous: LocationPing?,
        now: Date = Date(),
        minimumDistanceMeters: Double = LocationPingPolicy.minimumDistanceMeters,
        minimumInterval: TimeInterval = LocationPingPolicy.minimumInterval,
        heartbeatInterval: TimeInterval = LocationPingPolicy.heartbeatInterval
    ) -> LocationPing? {
        guard let previous else {
            return stamped(candidate, at: now)
        }

        let elapsed = now.timeIntervalSince(previous.updatedAt)
        let distance = haversineMeters(
            lat1: previous.latitude,
            lon1: previous.longitude,
            lat2: candidate.latitude,
            lon2: candidate.longitude
        )

        let movedEnough = distance >= minimumDistanceMeters
        let intervalElapsed = elapsed >= minimumInterval
        let heartbeatDue = elapsed >= heartbeatInterval

        if (movedEnough && intervalElapsed) || heartbeatDue {
            return stamped(candidate, at: now)
        }
        return nil
    }

    private static func stamped(_ ping: LocationPing, at date: Date) -> LocationPing {
        var copy = ping
        copy.updatedAt = date
        return copy
    }

    /// Great-circle distance in meters (WGS84 approximation).
    public static func haversineMeters(
        lat1: Double,
        lon1: Double,
        lat2: Double,
        lon2: Double
    ) -> Double {
        let earthRadiusMeters = 6_371_000.0
        let φ1 = lat1 * .pi / 180
        let φ2 = lat2 * .pi / 180
        let Δφ = (lat2 - lat1) * .pi / 180
        let Δλ = (lon2 - lon1) * .pi / 180

        let a = sin(Δφ / 2) * sin(Δφ / 2)
            + cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadiusMeters * c
    }
}

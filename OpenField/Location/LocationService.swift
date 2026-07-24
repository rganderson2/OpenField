import CoreLocation
import Foundation

/// Main-actor wrapper around `CLLocationManager`.
/// Does not start updates at launch — callers invoke `startUpdatingLocation()` / `stopUpdatingLocation()`.
@MainActor
public final class LocationService: NSObject, LocationProviding {
    private let manager: CLLocationManager

    public private(set) var lastLocation: CLLocation?
    public private(set) var isUpdating = false

    public var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    public override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = LocationPingPolicy.minimumDistanceMeters
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = .fitness
    }

    public func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    public func startUpdatingLocation() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        isUpdating = true
        manager.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        isUpdating = false
        manager.stopUpdatingLocation()
    }

    public func pingIfNeeded(
        candidate: LocationPing,
        previous: LocationPing?,
        now: Date = Date()
    ) -> LocationPing? {
        LocationPingThrottle.pingIfNeeded(
            candidate: candidate,
            previous: previous,
            now: now
        )
    }
}

extension LocationService: CLLocationManagerDelegate {
    public nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.lastLocation = location
        }
    }

    public nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Scaffolding: surface via logging/UI later. Avoid crashing on transient GPS errors.
        _ = error
    }

    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Callers observe `authorizationStatus` when building permission UI later.
    }
}

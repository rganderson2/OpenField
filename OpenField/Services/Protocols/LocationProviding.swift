import CoreLocation
import Foundation

/// Authorization and delivery of device location, plus ping throttle helpers.
@MainActor
public protocol LocationProviding: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var lastLocation: CLLocation? { get }
    var isUpdating: Bool { get }

    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()

    /// Pure policy gate: returns a candidate ping when distance/time rules say so.
    /// Does not publish; callers decide whether to write via `EventStore`.
    func pingIfNeeded(
        candidate: LocationPing,
        previous: LocationPing?,
        now: Date
    ) -> LocationPing?
}

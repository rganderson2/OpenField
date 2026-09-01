import XCTest
@testable import OpenField

final class LocationPingThrottleTests: XCTestCase {
    private let eventId = UUID()
    private let userId = UUID()

    func testFirstPingAlwaysAllowed() {
        let candidate = makePing(lat: 37.77, lon: -122.42, at: Date(timeIntervalSince1970: 1_000))
        let result = LocationPingThrottle.pingIfNeeded(candidate: candidate, previous: nil, now: Date(timeIntervalSince1970: 1_000))
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.latitude, 37.77)
    }

    func testRejectsWhenTooCloseAndTooSoon() {
        let previous = makePing(lat: 37.7700, lon: -122.4200, at: Date(timeIntervalSince1970: 1_000))
        // ~5 m north, 5 seconds later — under 20 m and 10 s thresholds.
        let candidate = makePing(lat: 37.770045, lon: -122.4200, at: Date(timeIntervalSince1970: 1_005))
        let result = LocationPingThrottle.pingIfNeeded(
            candidate: candidate,
            previous: previous,
            now: Date(timeIntervalSince1970: 1_005)
        )
        XCTAssertNil(result)
    }

    func testAllowsWhenMovedAndIntervalElapsed() {
        let previous = makePing(lat: 37.7700, lon: -122.4200, at: Date(timeIntervalSince1970: 1_000))
        // ~25 m north, 12 seconds later.
        let candidate = makePing(lat: 37.770225, lon: -122.4200, at: Date(timeIntervalSince1970: 1_012))
        let result = LocationPingThrottle.pingIfNeeded(
            candidate: candidate,
            previous: previous,
            now: Date(timeIntervalSince1970: 1_012)
        )
        XCTAssertNotNil(result)
    }

    func testHeartbeatAllowsWithoutMovement() {
        let previous = makePing(lat: 37.7700, lon: -122.4200, at: Date(timeIntervalSince1970: 1_000))
        let candidate = makePing(lat: 37.7700, lon: -122.4200, at: Date(timeIntervalSince1970: 1_060))
        let result = LocationPingThrottle.pingIfNeeded(
            candidate: candidate,
            previous: previous,
            now: Date(timeIntervalSince1970: 1_060)
        )
        XCTAssertNotNil(result)
    }

    func testHaversineKnownDistance() {
        // Roughly 111 km per degree latitude.
        let meters = LocationPingThrottle.haversineMeters(
            lat1: 0,
            lon1: 0,
            lat2: 0.001,
            lon2: 0
        )
        XCTAssertEqual(meters, 111.2, accuracy: 1.0)
    }

    private func makePing(lat: Double, lon: Double, at date: Date) -> LocationPing {
        LocationPing(
            eventId: eventId,
            userId: userId,
            displayName: "Tester",
            latitude: lat,
            longitude: lon,
            updatedAt: date
        )
    }
}

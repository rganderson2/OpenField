import XCTest
@testable import OpenField

final class InMemoryEventStoreTests: XCTestCase {
    func testCreateAndJoinEvent() async throws {
        let store = InMemoryEventStore()
        let hostId = UUID()
        let event = try await store.createEvent(
            RallyEvent(
                title: "Park Rally",
                joinCode: "abcd",
                hostUserId: hostId
            )
        )

        XCTAssertEqual(event.joinCode, "ABCD")
        XCTAssertEqual(event.status, .draft)

        let byCode = try await store.event(joinCode: "abcd")
        XCTAssertEqual(byCode.id, event.id)

        let playerId = UUID()
        let membership = try await store.joinEvent(
            eventId: event.id,
            userId: playerId,
            displayName: "Alex"
        )
        XCTAssertFalse(membership.isHost)
        XCTAssertEqual(membership.eventId, event.id)

        let members = try await store.memberships(eventId: event.id)
        XCTAssertEqual(members.count, 2)
    }

    func testCloudKitStubThrowsNotImplemented() async {
        let store = CloudKitEventStore()
        do {
            _ = try await store.event(id: UUID())
            XCTFail("Expected notImplemented")
        } catch let error as EventStoreError {
            guard case .notImplemented = error else {
                return XCTFail("Unexpected error \(error)")
            }
        } catch {
            XCTFail("Unexpected error type \(error)")
        }
    }
}

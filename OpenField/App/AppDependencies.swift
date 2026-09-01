import Foundation
import Observation
import SwiftUI

/// Composition root for injectable services.
/// Feature screens will read this via environment later; no product UI here.
@Observable
@MainActor
public final class AppDependencies {
    public let eventStore: any EventStore
    public let locationService: LocationService

    /// Reserved for swapping in a real CloudKit adapter once entitlements exist.
    public let cloudEventStore: CloudKitEventStore

    public init(
        eventStore: any EventStore = InMemoryEventStore(),
        locationService: LocationService? = nil,
        cloudEventStore: CloudKitEventStore = CloudKitEventStore()
    ) {
        self.eventStore = eventStore
        self.locationService = locationService ?? LocationService()
        self.cloudEventStore = cloudEventStore
    }

    public static let shared = AppDependencies()
}

/// Optional box keeps `EnvironmentKey.defaultValue` nonisolated (Swift 6–safe).
private struct AppDependenciesBoxKey: EnvironmentKey {
    static let defaultValue: AppDependencies? = nil
}

public extension EnvironmentValues {
    @MainActor
    var appDependencies: AppDependencies {
        get { self[AppDependenciesBoxKey.self] ?? .shared }
        set { self[AppDependenciesBoxKey.self] = newValue }
    }
}

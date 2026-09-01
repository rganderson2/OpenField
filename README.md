# OpenField

iOS scaffolding for co-located outdoor team events (scavenger hunt / checkpoint style). This repository establishes the architectural skeleton only — **no product UI screens** and **no live network / CloudKit I/O**.

## Open in Xcode

1. Open `OpenField.xcodeproj` in Xcode 15+ (tested against Xcode 26 tooling).
2. Select the **OpenField** shared scheme.
3. Choose an iOS 17+ Simulator and Run (⌘R).
4. Run unit tests with ⌘U (throttle policy tests do not need UI).

Bundle ID: `com.fieldrally.app` · Deployment target: **iOS 17** · Language: Swift 5.9+ · Lifecycle: SwiftUI `App`

Zero third-party SPM dependencies.

## Architecture overview

```
OpenField/
├── App/                  # Entry point + composition root (DI)
├── Domain/
│   ├── Models/           # Codable/Sendable value types
│   ├── Policies/         # Location ping throttle constants + pure logic
│   └── Errors/           # LocalizedError enums
├── Services/
│   ├── Protocols/        # EventStore, LocationProviding, EventSyncing
│   ├── Local/            # InMemoryEventStore (process-local)
│   └── CloudKit/         # Record keys, mapper sketch, notImplemented stub
├── Location/             # CLLocationManager wrapper (when-in-use)
├── Mapping/              # MapKit coordinate / annotation adapters (no Views)
└── Resources/            # Info.plist, Assets
```

### Boundaries

| Layer | Responsibility |
| --- | --- |
| **Domain** | Pure models + policy. No MapKit / CloudKit / UIKit imports. |
| **Services** | Protocol-oriented persistence/sync. Swap `InMemoryEventStore` ↔ `CloudKitEventStore` without rewriting domain logic. |
| **Location** | `@MainActor` `LocationService` wrapping `CLLocationManager`. Start/stop only; never auto-starts at launch. |
| **Mapping** | Conversions between domain lat/lon Doubles and `CLLocationCoordinate2D` / annotation IDs. |
| **App** | `AppDependencies` (`@Observable`) holds injectable services for future SwiftUI screens. |

### What’s stubbed vs real

| Piece | Status |
| --- | --- |
| Domain models | Implemented |
| `LocationPingPolicy` + `LocationPingThrottle.pingIfNeeded` | Implemented (pure; unit tested) |
| `InMemoryEventStore` | Full in-process implementation |
| `LocationService` | Real Core Location wrapper; callers must start/stop |
| MapKit helpers | Pure adapters only — **no map screens** |
| `CloudKitEventStore` | Throws `EventStoreError.notImplemented` |
| CloudKit entitlements / container | **Not enabled** (see below) |
| Product UI | Blank `ContentView` only |

## Enabling CloudKit later

When ready to implement the real store:

1. In Xcode → Signing & Capabilities → add **iCloud** with CloudKit.
2. Create / select a container (e.g. `iCloud.com.fieldrally.app`).
3. Define the record types named in `CloudKitRecordType` (`FieldEvent`, `FieldTeam`, `FieldMarker`, …).
4. Implement `CloudKitEventStore` using `CloudKitFieldKey` / `CloudKitRecordMapper` as the field contract.
5. Swap the default in `AppDependencies` from `InMemoryEventStore()` to the CloudKit adapter (keep in-memory for previews/tests).

Do **not** call `CKContainer.default()` until the capability and container exist for your team.

## Suggested implementation order

1. **CloudKitEventStore** — real saves/fetches/subscriptions against the record schema above.
2. **Host flow UI** — create event, rules, teams, join code (wired to `EventStore`).
3. **Live map** — MapKit markers + teammate pings using `Mapping/` adapters and `LocationService`.
4. **Chat** — event-wide text using `ChatMessage` + store methods.
5. Profile / settings and leave/end event polish.

## Location notes

- Accuracy: `kCLLocationAccuracyNearestTenMeters`
- `distanceFilter` aligned to `LocationPingPolicy.minimumDistanceMeters` (20 m)
- When-in-use only (`NSLocationWhenInUseUsageDescription` in Info.plist)
- Ping publish gate: 20 m **and** 10 s, or heartbeat every 60 s

## License / cost posture

Prefer Apple frameworks only (SwiftUI, MapKit, Core Location, CloudKit later). No Firebase, Google Maps, or paid chat SDKs in scope.

## Cursor Cloud Agents

Cloud environment config lives in `.cursor/environment.json` (install script + `AGENTS.md`).

1. Open [Cursor Cloud Agents](https://cursor.com/dashboard/cloud-agents) → **New Environment**
2. Select **`rganderson2/OpenField`** (repo must be accessible to the Cursor GitHub App)
3. Click **Start Agent** — the install script runs during the first Build (~10–20 min)
4. After success, future cloud/mobile agents start from the saved Build

Cloud VMs are Linux: agents edit Swift and open PRs here; **Xcode builds run on macOS** locally.

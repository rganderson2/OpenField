# OpenField — Agent Instructions

Outdoor co-located team events (scavenger hunt / checkpoint style). iOS 17+, SwiftUI, MapKit, Core Location, CloudKit (stubbed).

## Architecture (read first)

```
OpenField/App/           — OpenFieldApp, AppDependencies (DI), blank ContentView
OpenField/Domain/        — Models, policies, errors (no MapKit/CloudKit)
OpenField/Services/      — EventStore protocol, InMemoryEventStore, CloudKit stub
OpenField/Location/      — LocationService (CLLocationManager wrapper)
OpenField/Mapping/       — MapKit coordinate adapters (no Views)
```

Protocol-oriented boundaries: swap `InMemoryEventStore` ↔ `CloudKitEventStore` without rewriting domain logic.

## Scope constraints

- **No product UI** unless explicitly requested (no Home/Host/Map/Chat screens).
- **No live CloudKit / network I/O** unless explicitly requested.
- Prefer zero third-party SPM dependencies.
- Keep MapKit imports in `OpenField/Mapping/` only; domain models use `Double` lat/lon.

## Cursor Cloud specific instructions

Cloud agents run on **Linux (Ubuntu)**. This repo is an **iOS/Xcode** project.

### What cloud agents CAN do here

- Edit Swift source under `OpenField/` and `OpenFieldTests/`
- Extend domain models, protocols, in-memory store, CloudKit stubs, docs
- Review architecture and propose PRs
- Run `./.cursor/install.sh` (also invoked automatically during Builds)

### What cloud agents CANNOT do here

- Run `xcodebuild`, iOS Simulator, or sign iOS apps (requires macOS + Xcode)
- Enable CloudKit entitlements or test on-device location
- Assume `swift build` works for the full app target (Apple-only frameworks)

### Verification on cloud

After code changes, run the install script to confirm repo integrity:

```bash
./.cursor/install.sh
```

Full compile/test loop happens on **macOS**:

```bash
xcodebuild -project OpenField.xcodeproj -scheme OpenField \
  -destination 'platform=iOS Simulator,name=iPhone 17' build test
```

Document in PR notes when iOS-only verification was not run in cloud.

#### Optional: run the portable subset on Linux (supplementary)

The install script only checks repo integrity — it does not compile Swift. To
actually compile and unit-test the core logic on Linux, note that `Domain/`,
`Services/Local/`, `Services/CloudKit/`, and
`Services/Protocols/{EventStore,EventSyncing}.swift` import only `Foundation`,
and **both** XCTest suites (`OpenFieldTests/InMemoryEventStoreTests.swift`,
`OpenFieldTests/LocationPingThrottleTests.swift`) reference only that portable
subset. They can be built/run on **Swift-for-Linux** via a *standalone* SwiftPM
harness built **outside** the repo (do not add a `Package.swift` — it is
Xcode-only by design):

1. Install a Swift toolchain (e.g. `swiftly install latest`) plus its apt deps
   (`gnupg2 libcurl4-openssl-dev libpython3-dev libxml2-dev libncurses-dev libz3-dev`).
2. Create a SwiftPM package with module name **`OpenField`** (so
   `@testable import OpenField` resolves) and test target `OpenFieldTests`. Copy
   in the portable sources above plus the two test files unmodified, then
   `swift build` / `swift test`.

Do **not** copy these non-portable files into the harness — they need Apple
frameworks: `Location/LocationService.swift`, `Mapping/MapCoordinateAdapters.swift`,
`App/*.swift`, `Services/Protocols/LocationProviding.swift`. This subset run is
supplementary only; it is **not** the product's real build and does not cover UI,
MapKit/CoreLocation wrappers, or the SwiftUI app target.

## Implementation order (when building features)

1. `CloudKitEventStore` (real adapter)
2. Host flow UI
3. Live map (MapKit markers + location pings)
4. Event chat
5. Profile / settings polish

## Key files

| Concern | Location |
| --- | --- |
| Event persistence API | `OpenField/Services/Protocols/EventStore.swift` |
| Local store (tests/previews) | `OpenField/Services/Local/InMemoryEventStore.swift` |
| CloudKit stub | `OpenField/Services/CloudKit/CloudKitEventStore.swift` |
| Location throttle policy | `OpenField/Domain/Policies/LocationPingThrottle.swift` |
| DI composition root | `OpenField/App/AppDependencies.swift` |

# OpenField

Native **iOS** app (Swift 5.9+/SwiftUI, iOS 17 min, Xcode `.xcodeproj`) scaffolding
co-located outdoor team events. See `README.md` for architecture and build/run steps.

> Note: the product code lives on branch `scaffold/ios-architecture`, not `main`
> (which is an empty scaffold containing only `.gitattributes`).

## Cursor Cloud specific instructions

### Platform reality (read first)
- This is an iOS/Xcode app. The **real** build/run/test/lint path is **macOS + Xcode 15+**:
  open `OpenField.xcodeproj`, select the `OpenField` scheme, pick an iOS 17+ Simulator,
  Run (⌘R) / Test (⌘U). See `README.md`. There is **no lint tooling** configured
  (no SwiftLint/SwiftFormat); linting is limited to Xcode / `xcodebuild analyze`.
- The Cursor Cloud VM is **Linux**. You **cannot** build or run the full app, launch an
  iOS Simulator, or run `xcodebuild` here — Xcode is macOS-only, and the app imports
  Apple-only frameworks (`SwiftUI`, `MapKit`, `CoreLocation`, `Observation`, `CloudKit`).
  Full end-to-end verification must be done on a macOS host.
- There is **no package manager, no dependencies, no CI, no Docker**. The update script
  is intentionally a no-op; nothing needs installing to work with the repo.

### What you *can* verify on Linux (non-obvious)
The `Domain/`, `Services/Local/`, `Services/CloudKit/`, and
`Services/Protocols/{EventStore,EventSyncing}.swift` files import only `Foundation`,
and **both** XCTest suites (`OpenFieldTests/InMemoryEventStoreTests.swift`,
`OpenFieldTests/LocationPingThrottleTests.swift`) reference only that portable subset.
So the core domain/services logic and the existing unit tests can be compiled and run on
**Swift-for-Linux** via a *standalone* SwiftPM harness built **outside** the repo (do not
add a `Package.swift` to the repo — it is Xcode-only by design):

1. Install a Swift toolchain (e.g. `swiftly install latest`) plus its apt deps
   (`gnupg2 libcurl4-openssl-dev libpython3-dev libxml2-dev libncurses-dev libz3-dev`).
2. Create a SwiftPM package with module name **`OpenField`** (so `@testable import OpenField`
   resolves) and test target `OpenFieldTests`. Copy in the portable sources above plus the
   two test files unmodified, then `swift build` / `swift test`.

**Do not** copy these non-portable files into the harness — they need Apple frameworks:
`Location/LocationService.swift`, `Mapping/MapCoordinateAdapters.swift`, `App/*.swift`,
`Services/Protocols/LocationProviding.swift`.

This subset run is supplementary evidence only; it is **not** the product's real build and
does not cover UI, MapKit/CoreLocation wrappers, or the SwiftUI app target.

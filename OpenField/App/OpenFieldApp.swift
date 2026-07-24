import SwiftUI

@main
struct OpenFieldApp: App {
    @State private var dependencies = AppDependencies.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appDependencies, dependencies)
        }
    }
}

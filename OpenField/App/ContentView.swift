import SwiftUI

/// Placeholder root view so the app target compiles.
/// Product screens (Home / Host / Map / Chat / Settings) are intentionally absent.
struct ContentView: View {
    var body: some View {
        Color.clear
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

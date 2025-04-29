import SwiftUI

// Define placeholder view 
struct MainContentView: View {
    var body: some View {
        NavigationStack {
            Text("Language Byte")
                .font(.headline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink(destination: Text("Settings")) {
                            Image(systemName: "gear")
                        }
                    }
                }
                .onAppear {
                    // At this point, we would load actual ContentView at runtime
                    print("Main app started")
                }
        }
    }
}

// Removed @main
struct LanguageByteAppView: App {
    var body: some Scene {
        WindowGroup {
            MainContentView()
        }
    }
} 
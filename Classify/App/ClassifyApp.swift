import SwiftUI

@main
struct ClassifyApp: App {
    @StateObject private var store = WorkoutStore()
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var watchManager = WatchConnectivityManager()

    init() {
        // Wire up after @StateObject init via post-init injection
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(sessionManager)
                .environmentObject(watchManager)
                .onAppear {
                    watchManager.delegate = sessionManager
                }
        }
    }
}

import SwiftUI

@main
struct ClassifyWatchApp: App {
    @StateObject private var motionManager = WatchMotionManager()
    @StateObject private var sessionManager = WatchSessionManager()

    var body: some Scene {
        WindowGroup {
            WorkoutWatchView(
                motionManager: motionManager,
                sessionManager: sessionManager
            )
        }
    }
}

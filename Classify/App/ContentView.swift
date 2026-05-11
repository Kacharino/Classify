import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HistoryView()
                .tabItem {
                    Label("Verlauf", systemImage: "clock")
                }
            WorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "plus.circle")
                }
        }
    }
}

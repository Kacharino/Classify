import SwiftUI

private let motivationQuotes = [
    "Bereit, Grenzen zu verschieben?",
    "Heute besser als gestern.",
    "Kein Fortschritt ohne Einsatz.",
    "Stärke entsteht im Widerstand.",
    "Jeder Satz zählt."
]

struct WorkoutView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var store: WorkoutStore
    @EnvironmentObject var watchManager: WatchConnectivityManager

    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer? = nil
    @State private var finishedSession: WorkoutSession? = nil
    @State private var showSummary = false

    private let quote: String = motivationQuotes[Int.random(in: 0..<motivationQuotes.count)]

    var body: some View {
        NavigationStack {
            Group {
                if sessionManager.isSessionActive {
                    activeView
                } else {
                    idleView
                }
            }
            .navigationTitle("Workout")
            .sheet(isPresented: $showSummary) {
                if let session = finishedSession {
                    SummaryView(session: session) {
                        showSummary = false
                        finishedSession = nil
                    }
                }
            }
        }
    }

    // MARK: - Idle

    private var idleView: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(quote)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: startWorkout) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 120, height: 120)
                    Text("Start")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Text("Drück Starten — die Watch öffnet sich automatisch.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    // MARK: - Active

    private var activeView: some View {
        VStack(spacing: 0) {
            // Timer row
            HStack(spacing: 8) {
                PulsingDot()
                Text(formattedElapsed)
                    .font(.title3.monospacedDigit())
                    .foregroundStyle(.red)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Set count
            VStack(spacing: 4) {
                Text("\(sessionManager.currentSets.count)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                Text("Sätze aufgezeichnet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 16)

            Text(quote)
                .font(.footnote.italic())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 12)

            // Sets list
            List {
                ForEach(Array(sessionManager.currentSets.enumerated().reversed()), id: \.element.id) { index, set in
                    SetRowView(index: index + 1, set: set, highlightLowConfidence: true)
                }
            }
            .listStyle(.plain)

            // Stop button
            Button(action: stopWorkout) {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 90, height: 90)
                    Text("Stop")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Actions

    private func startWorkout() {
        sessionManager.startSession()
        watchManager.sendStartCommand()
        elapsedSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func stopWorkout() {
        timer?.invalidate()
        timer = nil
        watchManager.sendStopCommand()
        let session = sessionManager.endSession()
        store.addSession(session)
        finishedSession = session
        showSummary = true
    }

    private var formattedElapsed: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - PulsingDot

private struct PulsingDot: View {
    @State private var pulsing = false

    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 10, height: 10)
            .scaleEffect(pulsing ? 1.4 : 1.0)
            .opacity(pulsing ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulsing)
            .onAppear { pulsing = true }
    }
}

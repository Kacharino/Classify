import SwiftUI

struct WorkoutWatchView: View {
    @ObservedObject var motionManager: WatchMotionManager
    @ObservedObject var sessionManager: WatchSessionManager

    @State private var trainingElapsed: Int = 0
    @State private var setElapsed: Int = 0
    @State private var setCount: Int = 0
    @State private var showSent: Bool = false

    @State private var trainingTimer: Timer? = nil
    @State private var setTimer: Timer? = nil

    var body: some View {
        ZStack {
            if showSent {
                sentView
            } else if !sessionManager.isSessionActive {
                waitingView
            } else if motionManager.isRecording {
                recordingView
            } else {
                readyView
            }
        }
        .onChange(of: sessionManager.isSessionActive) { active in
            if active {
                startTrainingTimer()
            } else {
                stopAllTimers()
                trainingElapsed = 0
                setElapsed = 0
                setCount = 0
            }
        }
    }

    // MARK: - Waiting

    private var waitingView: some View {
        VStack(spacing: 8) {
            Text("Classify")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("Warte auf iPhone...")
                .font(.footnote)
                .foregroundStyle(.gray)
        }
    }

    // MARK: - Ready

    private var readyView: some View {
        VStack(spacing: 12) {
            Text(formattedTime(trainingElapsed))
                .font(.system(.title3, design: .monospaced))
                .foregroundStyle(.white)

            Button(action: startSet) {
                Text("Start")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
    }

    // MARK: - Recording

    private var recordingView: some View {
        VStack(spacing: 8) {
            Text(formattedTime(trainingElapsed))
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.gray)

            Text("Satz \(setCount + 1)")
                .font(.subheadline)
                .foregroundStyle(.gray)

            Text(formattedTime(setElapsed))
                .font(.system(.title, design: .monospaced).bold())
                .foregroundStyle(.white)

            Button(action: stopSet) {
                Text("Stop")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
    }

    // MARK: - Sent Confirmation

    private var sentView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.green)
            Text("Gesendet")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Satz \(setCount) aufgezeichnet")
                .font(.footnote)
                .foregroundStyle(.gray)
        }
    }

    // MARK: - Actions

    private func startSet() {
        setElapsed = 0
        startSetTimer()
        motionManager.startRecording()
    }

    private func stopSet() {
        let samples = motionManager.stopRecording()
        stopSetTimer()
        sessionManager.sendSamples(samples)
        setCount += 1

        showSent = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showSent = false
        }
    }

    // MARK: - Timers

    private func startTrainingTimer() {
        trainingElapsed = 0
        trainingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            trainingElapsed += 1
        }
    }

    private func startSetTimer() {
        setTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            setElapsed += 1
        }
    }

    private func stopSetTimer() {
        setTimer?.invalidate()
        setTimer = nil
    }

    private func stopAllTimers() {
        trainingTimer?.invalidate()
        trainingTimer = nil
        stopSetTimer()
    }

    // MARK: - Helpers

    private func formattedTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

import Foundation

class SessionManager: ObservableObject, WatchConnectivityDelegate {
    @Published var isSessionActive: Bool = false
    @Published var currentSets: [WorkoutSet] = []
    private(set) var sessionStartTime: Date?

    private let classifier: ExerciseClassifier

    init(classifier: ExerciseClassifier = ExerciseClassifier()) {
        self.classifier = classifier
    }

    func didReceiveSamples(_ samples: [[Double]]) {
        addRawSensorData(samples)
    }

    func didLoseConnection() {
        addConnectionLostSet()
    }

    func startSession() {
        currentSets = []
        sessionStartTime = Date()
        isSessionActive = true
    }

    @discardableResult
    func addRawSensorData(_ samples: [[Double]]) -> WorkoutSet {
        let (label, confidence) = classifier.classify(samples: samples)
        let set = WorkoutSet(
            exerciseLabel: label,
            confidence: confidence,
            isConnectionLost: false,
            timestamp: Date()
        )
        DispatchQueue.main.async {
            self.currentSets.append(set)
        }
        return set
    }

    func addConnectionLostSet() {
        let set = WorkoutSet(
            exerciseLabel: "",
            confidence: 0.0,
            isConnectionLost: true,
            timestamp: Date()
        )
        DispatchQueue.main.async {
            self.currentSets.append(set)
        }
    }

    func endSession() -> WorkoutSession {
        let start = sessionStartTime ?? Date()
        let duration = Date().timeIntervalSince(start)
        let session = WorkoutSession(
            date: start,
            sets: currentSets,
            duration: duration
        )
        currentSets = []
        sessionStartTime = nil
        isSessionActive = false
        return session
    }
}

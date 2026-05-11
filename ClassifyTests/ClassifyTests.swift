import XCTest
@testable import Classify

final class ClassifyTests: XCTestCase {

    // MARK: - Test A: ExerciseClassifier

    func testExerciseClassifierNoCrashAndValidOutput() {
        let classifier = ExerciseClassifier()

        // Synthetic input: 250 samples × 6 channels, all zeros
        let samples = Array(repeating: Array(repeating: 0.0, count: 6), count: 250)

        let (label, confidence) = classifier.classify(samples: samples)

        // Label must be a non-empty string from class_order (or the failure sentinel)
        let validLabels: Set<String> = [
            "squats", "lunges", "bicep_curls", "situps", "pushups",
            "tricep_extensions", "dumbbell_rows", "jumping_jacks",
            "dumbbell_shoulder_press", "lateral_shoulder_raises", "non-exercise"
        ]
        XCTAssertFalse(label.isEmpty, "Label must not be empty")
        XCTAssertTrue(validLabels.contains(label),
                      "Label '\(label)' must be a member of class_order")

        XCTAssertTrue(confidence.isFinite, "Confidence must be a finite number")
        XCTAssertGreaterThanOrEqual(confidence, 0.0, "Confidence must be >= 0.0")
        XCTAssertLessThanOrEqual(confidence, 1.0,   "Confidence must be <= 1.0")
    }

    func testExerciseClassifierPartialInput() {
        // Fewer than 250 samples — must not crash
        let classifier = ExerciseClassifier()
        let samples = Array(repeating: Array(repeating: 0.5, count: 6), count: 100)
        let (label, confidence) = classifier.classify(samples: samples)
        XCTAssertFalse(label.isEmpty)
        XCTAssertTrue(confidence.isFinite)
    }

    // MARK: - Test B: WorkoutStore Persistence

    func testWorkoutStorePersistenceRoundTrip() throws {
        // Setup: clean slate
        let store1 = WorkoutStore()
        store1.deleteAllSessions()

        // Build a session with exactly 3 sets
        let sets: [WorkoutSet] = [
            WorkoutSet(exerciseLabel: "pushups",  confidence: 0.91,
                       isConnectionLost: false, timestamp: Date()),
            WorkoutSet(exerciseLabel: "squats",   confidence: 0.85,
                       isConnectionLost: false, timestamp: Date()),
            WorkoutSet(exerciseLabel: "lunges",   confidence: 0.78,
                       isConnectionLost: false, timestamp: Date())
        ]
        let session = WorkoutSession(date: Date(), sets: sets, duration: 120.0)
        store1.addSession(session)

        // Simulate app restart by creating a fresh store that reads from disk
        let store2 = WorkoutStore()

        XCTAssertEqual(store2.sessions.count, 1, "One session should be persisted")
        XCTAssertEqual(store2.sessions[0].sets.count, 3, "Session must have 3 sets")
        XCTAssertEqual(store2.sessions[0].sets[0].exerciseLabel, "pushups")
        XCTAssertEqual(store2.sessions[0].sets[1].exerciseLabel, "squats")
        XCTAssertEqual(store2.sessions[0].sets[2].exerciseLabel, "lunges")

        // Teardown
        store2.deleteAllSessions()
    }

    func testWorkoutStoreMaxCapacity() {
        let store = WorkoutStore()
        store.deleteAllSessions()

        // Add 105 sessions — store should cap at 100
        for i in 0..<105 {
            let s = WorkoutSession(date: Date(), sets: [], duration: Double(i))
            store.addSession(s)
        }
        XCTAssertLessThanOrEqual(store.sessions.count, 100,
                                  "Store must not exceed 100 sessions")

        store.deleteAllSessions()
    }

    // MARK: - Test C: WorkoutSession computed properties

    func testWorkoutSessionComputedProperties() {
        let sets: [WorkoutSet] = [
            WorkoutSet(exerciseLabel: "pushups", confidence: 0.9,
                       isConnectionLost: false, timestamp: Date()),
            WorkoutSet(exerciseLabel: "pushups", confidence: 0.8,
                       isConnectionLost: false, timestamp: Date()),
            WorkoutSet(exerciseLabel: "squats",  confidence: 0.7,
                       isConnectionLost: false, timestamp: Date()),
            WorkoutSet(exerciseLabel: "",        confidence: 0.0,
                       isConnectionLost: true,  timestamp: Date())
        ]
        let session = WorkoutSession(date: Date(), sets: sets, duration: 2700)

        XCTAssertEqual(session.totalSets, 4)
        XCTAssertEqual(session.setCountPerExercise["pushups"], 2)
        XCTAssertEqual(session.setCountPerExercise["squats"],  1)
        XCTAssertNil(session.setCountPerExercise[""],
                     "Connection-lost sets must not appear in setCountPerExercise")
        XCTAssertEqual(session.formattedDuration, "45 min")
    }
}

import Foundation
import CoreML

class ExerciseClassifier {
    private var model: MLModel?
    private var means: [Double] = []
    private var stds: [Double] = []
    private var classOrder: [String] = []

    init() {
        loadArtifacts()
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            loadModel()
        }
    }

    // MARK: - Setup

    private func loadArtifacts() {
        let allJSON = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
        print("ExerciseClassifier: JSON files in bundle — \(allJSON)")

        let jsonURL = Bundle.main.url(forResource: "cnn_v2f_artifacts", withExtension: "json")
                   ?? Bundle.main.url(forResource: "cnn_v2f_artifacts", withExtension: "json",
                                      subdirectory: "Resources")
        guard let url = jsonURL else {
            print("ExerciseClassifier: cnn_v2f_artifacts.json not found in bundle")
            return
        }

        guard let data = try? Data(contentsOf: url) else {
            print("ExerciseClassifier: failed to read data from \(url)")
            return
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("ExerciseClassifier: JSON parse failed — file may be malformed")
            return
        }

        guard let normalization = json["normalization"] as? [String: Any] else {
            print("ExerciseClassifier: missing 'normalization' key — top-level keys: \(json.keys.sorted())")
            return
        }

        guard let config = json["config"] as? [String: Any] else {
            print("ExerciseClassifier: missing 'config' key — top-level keys: \(json.keys.sorted())")
            return
        }

        means = (normalization["mean"] as? [Double]) ?? []
        stds  = (normalization["std"]  as? [Double]) ?? []
        classOrder = (config["class_order"] as? [String]) ?? []
        print("ExerciseClassifier: artifacts loaded — \(classOrder.count) classes, \(means.count) mean values")
    }

    private func loadModel() {
        // 1. Prefer compiled .mlmodelc (Xcode build output)
        if let compiledURL = Bundle.main.url(forResource: "CNNModel_v3c", withExtension: "mlmodelc") {
            model = try? MLModel(contentsOf: compiledURL)
            if model != nil { return }
        }
        // 2. Fallback: compile .mlpackage at runtime
        let pkgURL = Bundle.main.url(forResource: "CNNModel_v3c", withExtension: "mlpackage")
                  ?? Bundle.main.url(forResource: "CNNModel_v3c", withExtension: "mlpackage",
                                     subdirectory: "Resources")
        guard let pkgURL else {
            print("ExerciseClassifier: model not found")
            return
        }
        do {
            let compiled = try MLModel.compileModel(at: pkgURL)
            model = try MLModel(contentsOf: compiled)
        } catch {
            print("ExerciseClassifier: model load error – \(error)")
        }
    }

    // MARK: - Inference

    private let windowSize = 250
    private let stride     = 25
    private let minWindows = 5
    private let channels   = 6

    /// Run one CNN forward pass on a pre-sliced window (already normalized).
    private func predictWindow(_ input: MLMultiArray, model: MLModel) -> [(label: String, confidence: Double)]? {
        guard let fp = try? MLDictionaryFeatureProvider(
            dictionary: ["x": MLFeatureValue(multiArray: input)]
        ),
        let result = try? model.prediction(from: fp) else { return nil }

        let outputName = result.featureNames.contains("Identity") ? "Identity" : result.featureNames.first
        guard let name = outputName,
              let arr  = result.featureValue(for: name)?.multiArrayValue else { return nil }

        var ranked: [(label: String, confidence: Double)] = []
        for i in 0..<arr.count {
            let label = i < classOrder.count ? classOrder[i] : "non-exercise"
            ranked.append((label, Double(arr[i].floatValue)))
        }
        return ranked.sorted { $0.confidence > $1.confidence }
    }

    /// Classify a stream of sensor data using sliding window + majority vote.
    /// - Parameter samples: N rows × 6 columns [ax, ay, az, gx, gy, gz], N ≥ 250
    /// - Returns: (label, confidence)
    func classify(samples: [[Double]]) -> (label: String, confidence: Double) {
        guard let model else { return ("non-exercise", 0.0) }
        guard !means.isEmpty, !stds.isEmpty, !classOrder.isEmpty else { return ("non-exercise", 0.0) }
        guard samples.count >= windowSize else { return ("non-exercise", 0.0) }

        // --- DEBUG: normalization diagnostics (remove after investigation) ---
        print("DEBUG means: \(means)")
        print("DEBUG stds:  \(stds)")
        let rawSlice = samples.prefix(5)
        for (i, row) in rawSlice.enumerated() {
            print("DEBUG RAW sample \(i): \(row)")
        }
        for (i, row) in rawSlice.enumerated() {
            let normed = row.enumerated().map { (c, raw) -> Double in
                guard c < means.count, c < stds.count, stds[c] != 0 else { return 0.0 }
                return (raw - means[c]) / stds[c]
            }
            print("DEBUG NORM sample \(i): \(normed)")
        }
        // --- END DEBUG ---

        // Collect predictions from all sliding windows
        var allResults: [(label: String, confidence: Double)] = []
        var windowIndex = 0
        var start = 0
        while start + windowSize <= samples.count {
            guard let input = try? MLMultiArray(
                shape: [1, NSNumber(value: windowSize), NSNumber(value: channels)],
                dataType: .float32
            ) else { start += stride; continue }

            for t in 0..<windowSize {
                let row = samples[start + t]
                for c in 0..<channels {
                    let raw  = c < row.count ? row[c] : 0.0
                    let norm = stds[c] != 0 ? (raw - means[c]) / stds[c] : 0.0
                    input[t * channels + c] = NSNumber(value: Float(norm))
                }
            }

            if let ranked = predictWindow(input, model: model), let top1 = ranked.first {
                let topStr = ranked.prefix(3).map { String(format: "%@ (%.3f)", $0.label, $0.confidence) }.joined(separator: " | ")
                print("WINDOW \(windowIndex): \(topStr)")
                allResults.append((label: top1.label, confidence: top1.confidence))
            }
            windowIndex += 1
            start += stride
        }

        let totalWindows = allResults.count
        guard totalWindows >= minWindows else { return ("non-exercise", 0.0) }

        // Filter out ALL non-exercise windows
        let exerciseResults = allResults.filter { $0.label != "non-exercise" }
        let filteredCount   = totalWindows - exerciseResults.count

        guard !exerciseResults.isEmpty else {
            print("DEBUG windows: total=\(totalWindows)  non_ex_filtered=\(filteredCount)  winner=non-exercise  votes=0/0 (0%)")
            return ("non-exercise", 0.0)
        }

        // Simple majority vote — count only, no confidence weighting
        var votes: [String: Int] = [:]
        for r in exerciseResults {
            votes[r.label, default: 0] += 1
        }

        let winner    = votes.max { $0.value < $1.value }!
        let winLabel  = winner.key
        let winVotes  = winner.value
        let voteShare = Double(winVotes) / Double(exerciseResults.count)

        // Avg confidence for display only
        let avgConf = exerciseResults.filter { $0.label == winLabel }.map { $0.confidence }.reduce(0, +) / Double(winVotes)

        guard voteShare >= 0.30 else {
            print("DEBUG windows: total=\(totalWindows)  non_ex_filtered=\(filteredCount)  winner=\(winLabel)  votes=\(winVotes)/\(exerciseResults.count) (\(String(format: "%.0f", voteShare * 100))%)  → rejected (< 30%)")
            return ("non-exercise", 0.0)
        }

        print("DEBUG windows: total=\(totalWindows)  non_ex_filtered=\(filteredCount)  winner=\(winLabel)  votes=\(winVotes)/\(exerciseResults.count) (\(String(format: "%.0f", voteShare * 100))%)")

        return (winLabel, avgConf)
    }
}

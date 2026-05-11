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
        let jsonURL = Bundle.main.url(forResource: "cnn_v2f_artifacts", withExtension: "json")
                   ?? Bundle.main.url(forResource: "cnn_v2f_artifacts", withExtension: "json",
                                      subdirectory: "Resources")
        guard let url = jsonURL,
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let normalization = json["normalization"] as? [String: Any],
              let config = json["config"] as? [String: Any]
        else {
            print("ExerciseClassifier: failed to load artifacts JSON")
            return
        }

        means = (normalization["mean"] as? [Double]) ?? []
        stds  = (normalization["std"]  as? [Double]) ?? []
        classOrder = (config["class_order"] as? [String]) ?? []
    }

    private func loadModel() {
        // 1. Prefer compiled .mlmodelc (Xcode build output)
        if let compiledURL = Bundle.main.url(forResource: "CNNModel_test", withExtension: "mlmodelc") {
            model = try? MLModel(contentsOf: compiledURL)
            if model != nil { return }
        }
        // 2. Fallback: compile .mlpackage at runtime
        let pkgURL = Bundle.main.url(forResource: "CNNModel_test", withExtension: "mlpackage")
                  ?? Bundle.main.url(forResource: "CNNModel_test", withExtension: "mlpackage",
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

                var effectiveLabel = top1.label
                var effectiveConf  = top1.confidence
                if top1.label == "non-exercise",
                   let jj = ranked.first(where: { $0.label == "jumping_jacks" }),
                   jj.confidence > 0.15 {
                    effectiveLabel = "jumping_jacks"
                    effectiveConf  = jj.confidence
                    print("WINDOW \(windowIndex): non-exercise overridden → jumping_jacks (\(String(format: "%.3f", jj.confidence)))")
                }

                allResults.append((label: effectiveLabel, confidence: effectiveConf))
            }
            windowIndex += 1
            start += stride
        }

        let totalWindows = allResults.count
        guard totalWindows >= minWindows else { return ("non-exercise", 0.0) }

        // Filter out non-exercise windows
        let exerciseResults = allResults.filter { $0.label != "non-exercise" }
        let filteredCount   = totalWindows - exerciseResults.count

        guard !exerciseResults.isEmpty else {
            print("DEBUG windows: total=\(totalWindows)  non_ex_filtered=\(filteredCount)  winner=non-exercise  votes=0/0 (0%)  confidence=0.000")
            return ("non-exercise", 0.0)
        }

        // Group by label → count votes + accumulate confidence
        var votes: [String: (count: Int, totalConf: Double)] = [:]
        for r in exerciseResults {
            let cur = votes[r.label] ?? (0, 0.0)
            votes[r.label] = (cur.count + 1, cur.totalConf + r.confidence)
        }

        // Winner: most votes; tie-break by avg confidence
        let winner = votes.max {
            if $0.value.count != $1.value.count { return $0.value.count < $1.value.count }
            return ($0.value.totalConf / Double($0.value.count)) < ($1.value.totalConf / Double($1.value.count))
        }!

        let winLabel  = winner.key
        let winVotes  = winner.value.count
        let avgConf   = winner.value.totalConf / Double(winVotes)
        let voteShare = Double(winVotes) / Double(exerciseResults.count)

        guard voteShare >= 0.30 else {
            print("DEBUG windows: total=\(totalWindows)  non_ex_filtered=\(filteredCount)  winner=\(winLabel)  votes=\(winVotes)/\(exerciseResults.count) (\(String(format: "%.0f", voteShare * 100))%)  confidence=\(String(format: "%.3f", avgConf))  → rejected (< 30%)")
            return ("non-exercise", 0.0)
        }

        print("DEBUG windows: total=\(totalWindows)  non_ex_filtered=\(filteredCount)  winner=\(winLabel)  votes=\(winVotes)/\(exerciseResults.count) (\(String(format: "%.0f", voteShare * 100))%)  confidence=\(String(format: "%.3f", avgConf))")

        return (winLabel, avgConf)
    }
}

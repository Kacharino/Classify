import Foundation

struct WorkoutSession: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var sets: [WorkoutSet]
    var duration: TimeInterval

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        if minutes < 1 { return "< 1 min" }
        return "\(minutes) min"
    }

    var setCountPerExercise: [String: Int] {
        var counts: [String: Int] = [:]
        for set in sets where !set.isConnectionLost {
            counts[set.exerciseLabel, default: 0] += 1
        }
        return counts
    }

    var totalSets: Int { sets.count }
}

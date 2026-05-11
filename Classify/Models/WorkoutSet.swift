import Foundation

struct WorkoutSet: Identifiable, Codable {
    var id: UUID = UUID()
    var exerciseLabel: String
    var confidence: Double
    var isConnectionLost: Bool
    var timestamp: Date
}

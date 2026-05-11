import Foundation

class WorkoutStore: ObservableObject {
    @Published var sessions: [WorkoutSession] = []

    private let maxSessions = 100
    private let fileName = "workout_sessions.json"

    private var fileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    func addSession(_ session: WorkoutSession) {
        sessions.insert(session, at: 0)
        if sessions.count > maxSessions {
            sessions = Array(sessions.prefix(maxSessions))
        }
        save()
    }

    func deleteSession(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        save()
    }

    func deleteAllSessions() {
        sessions.removeAll()
        save()
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(sessions)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("WorkoutStore save error: \(error)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            sessions = try JSONDecoder().decode([WorkoutSession].self, from: data)
        } catch {
            print("WorkoutStore load error: \(error)")
        }
    }
}

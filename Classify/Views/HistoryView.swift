import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: WorkoutStore

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        NavigationStack {
            Group {
                if store.sessions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Noch keine Workouts")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Starte dein erstes Training im Workout-Tab.")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(store.sessions) { session in
                            SessionRow(session: session, dateFormatter: dateFormatter)
                        }
                        .onDelete(perform: store.deleteSession)
                    }
                }
            }
            .navigationTitle("Verlauf")
            .toolbar {
                if !store.sessions.isEmpty {
                    EditButton()
                }
            }
        }
    }
}

// MARK: - SessionRow

private struct SessionRow: View {
    let session: WorkoutSession
    let dateFormatter: DateFormatter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateFormatter.string(from: session.date))
                    .font(.headline)
                Spacer()
                Text(session.formattedDuration)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                Image(systemName: "list.bullet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(session.totalSets) Sätze")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !session.setCountPerExercise.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(session.setCountPerExercise.sorted(by: { $0.key < $1.key }), id: \.key) { name, count in
                        HStack(spacing: 4) {
                            Text(formattedLabel(name))
                                .font(.caption)
                            Text("\(count)")
                                .font(.caption.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formattedLabel(_ raw: String) -> String {
        raw.replacingOccurrences(of: "_", with: " ").capitalized
    }
}


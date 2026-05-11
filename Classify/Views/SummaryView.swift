import SwiftUI

struct SummaryView: View {
    let session: WorkoutSession
    var onDismiss: () -> Void

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        NavigationStack {
            List {
                // Saved banner
                Section {
                    HStack {
                        Spacer()
                        Label("Gespeichert", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.green)
                        Spacer()
                    }
                }

                // Summary stats
                Section("Zusammenfassung") {
                    LabeledContent("Datum", value: dateFormatter.string(from: session.date))
                    LabeledContent("Dauer", value: session.formattedDuration)
                    LabeledContent("Sätze gesamt", value: "\(session.totalSets)")
                    LabeledContent("Übungen", value: "\(session.setCountPerExercise.count)")
                }

                // Sets list
                Section("Sätze") {
                    ForEach(Array(session.sets.enumerated()), id: \.element.id) { index, set in
                        HStack {
                            Text("\(index + 1).")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 28, alignment: .leading)

                            if set.isConnectionLost {
                                Label("Verbindung unterbrochen", systemImage: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.subheadline)
                            } else {
                                Text(set.exerciseLabel.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%.0f%%", set.confidence * 100))
                                    .font(.caption.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundStyle(.green)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .navigationTitle("Workout abgeschlossen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { onDismiss() }
                }
            }
        }
    }
}

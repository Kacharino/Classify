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
                        SetRowView(index: index + 1, set: set, highlightLowConfidence: false)
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

import SwiftUI

struct SetRowView: View {
    let index: Int
    let set: WorkoutSet
    var highlightLowConfidence: Bool = true

    var body: some View {
        HStack {
            Text("\(index).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .leading)

            if set.isConnectionLost {
                Label("Verbindung unterbrochen", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                    .font(.subheadline)
            } else {
                Text(set.exerciseLabel.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.subheadline)
                Spacer()
                confidenceBadge(set.confidence)
            }
        }
    }

    @ViewBuilder
    private func confidenceBadge(_ confidence: Double) -> some View {
        let isLow = highlightLowConfidence && confidence < 0.5
        HStack(spacing: 3) {
            if isLow {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            Text(String(format: "%.0f%%", confidence * 100))
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(isLow ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                .foregroundStyle(isLow ? .orange : .green)
                .clipShape(Capsule())
        }
    }
}

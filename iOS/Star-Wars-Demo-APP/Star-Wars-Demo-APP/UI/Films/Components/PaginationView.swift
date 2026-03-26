import SwiftUI

struct PaginationView: View {
    let current: Int
    let total: Int
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button("Previous", action: onPrevious)
                .buttonStyle(.bordered)
                .disabled(current <= 1)

            Text("Page \(current) / \(total)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(StarWarsColors.primary)

            Button("Next", action: onNext)
                .buttonStyle(.bordered)
                .disabled(current >= total)
        }
        .padding(.vertical, 12)
    }
}

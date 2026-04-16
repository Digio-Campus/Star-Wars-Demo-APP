import SwiftUI

/// A large title that smoothly scales down as the user scrolls.
///
/// Pass the ScrollView's vertical offset (typically `minY` from `ScrollOffsetReader`).
struct CollapsibleLargeTitleHeader: View {
    let title: String
    let scrollOffset: CGFloat

    var expandedScale: CGFloat = 1.3
    var collapsedScale: CGFloat = 0.9
    var collapseDistance: CGFloat = 80

    private var progress: CGFloat {
        // `minY` is ~0 at rest and becomes negative as the user scrolls down.
        let clamped = min(scrollOffset, 0)
        return min(max((-clamped) / collapseDistance, 0), 1)
    }

    private var scale: CGFloat {
        expandedScale + (collapsedScale - expandedScale) * progress
    }

    var body: some View {
        Text(title)
            .font(.title.weight(.bold))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .scaleEffect(scale, anchor: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

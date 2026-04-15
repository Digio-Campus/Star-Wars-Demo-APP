import SwiftUI

/// Emits the vertical scroll offset (minY) for the enclosing ScrollView's named coordinate space.
///
/// This is intentionally lightweight; callers should gate any state updates (e.g. only when a threshold is crossed)
/// to avoid per-frame state churn while scrolling.
enum ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollOffsetReader: View {
    let coordinateSpaceName: String

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: proxy.frame(in: .named(coordinateSpaceName)).minY
                )
        }
        .frame(height: 0)
    }
}

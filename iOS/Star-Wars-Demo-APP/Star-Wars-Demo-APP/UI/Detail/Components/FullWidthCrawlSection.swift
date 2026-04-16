import SwiftUI

/// Full-width section intended for the Opening Crawl.
///
/// Renders content edge-to-edge horizontally (no padding), but with internal padding
/// and background that spans the full width.
struct FullWidthCrawlSection<Content: View>: View {
    private let background: Color
    private let content: Content

    init(background: Color = StarWarsColors.surface, @ViewBuilder content: () -> Content) {
        self.background = background
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            background
                .ignoresSafeArea(.container, edges: [.horizontal])
        }
    }
}

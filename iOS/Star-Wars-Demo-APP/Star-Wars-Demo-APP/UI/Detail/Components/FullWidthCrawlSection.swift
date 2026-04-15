import SwiftUI

/// Full-width section intended for the Opening Crawl.
///
/// Unlike `FullWidthSection`, this deliberately does **not** apply horizontal padding,
/// so the content can truly render edge-to-edge.
struct FullWidthCrawlSection<Content: View>: View {
    private let background: Color
    private let content: Content

    init(background: Color = StarWarsColors.surface, @ViewBuilder content: () -> Content) {
        self.background = background
        self.content = content()
    }

    var body: some View {
        content
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                background
                    .ignoresSafeArea(.container, edges: [.horizontal])
            }
    }
}

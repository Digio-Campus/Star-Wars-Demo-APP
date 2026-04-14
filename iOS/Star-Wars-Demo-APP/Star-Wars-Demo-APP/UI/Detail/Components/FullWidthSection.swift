import SwiftUI

struct FullWidthSection<Content: View>: View {
    private let background: Color
    private let content: Content

    init(background: Color = StarWarsColors.surface, @ViewBuilder content: () -> Content) {
        self.background = background
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                background
                    .ignoresSafeArea(.container, edges: [.horizontal])
            }
    }
}

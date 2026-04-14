import SwiftUI

struct InfiniteScrollFooterView: View {
    let isLoading: Bool
    let canLoadMore: Bool
    let onLoadMore: () -> Void

    var body: some View {
        if canLoadMore {
            HStack {
                Spacer()
                ProgressView()
                    .opacity(isLoading ? 1 : 0)
                Spacer()
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onAppear(perform: onLoadMore)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
            .accessibilityHidden(!isLoading)
        }
    }
}

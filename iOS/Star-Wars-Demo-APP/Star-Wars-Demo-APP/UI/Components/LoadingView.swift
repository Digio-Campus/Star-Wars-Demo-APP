import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .tint(StarWarsColors.primary)
            .controlSize(.large)
    }
}

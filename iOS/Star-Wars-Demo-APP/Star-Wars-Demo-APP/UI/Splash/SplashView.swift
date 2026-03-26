import SwiftUI

struct SplashView: View {
    let onFinish: () -> Void

    var body: some View {
        ZStack {
            StarWarsColors.background.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("STAR")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                Text("WARS")
                    .font(.system(size: 44, weight: .black, design: .rounded))
            }
            .foregroundStyle(StarWarsColors.primary)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Star Wars")
        }
        .task {
            try? await Task.sleep(for: .seconds(1))
            onFinish()
        }
    }
}

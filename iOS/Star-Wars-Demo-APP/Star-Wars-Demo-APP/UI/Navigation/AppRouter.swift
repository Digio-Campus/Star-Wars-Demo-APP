import SwiftUI

struct AppRouter: View {
    let dependencies: DependencyContainer

    @State private var didFinishSplash = false

    var body: some View {
        Group {
            if didFinishSplash {
                MainTabView(dependencies: dependencies)
            } else {
                SplashView {
                    withAnimation(.easeOut(duration: 0.3)) {
                        didFinishSplash = true
                    }
                }
            }
        }
    }
}

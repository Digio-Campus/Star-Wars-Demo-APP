import SwiftUI

struct IOSTrailerPlayerView: UIViewControllerRepresentable {
    let source: VideoSource

    func makeUIViewController(context: Context) -> IOSTrailerPlayer {
        let vc = IOSTrailerPlayer()
        vc.load(source: source)
        vc.enableCasting()
        return vc
    }

    func updateUIViewController(_ uiViewController: IOSTrailerPlayer, context: Context) {
        uiViewController.load(source: source)
    }

    static func dismantleUIViewController(_ uiViewController: IOSTrailerPlayer, coordinator: ()) {
        uiViewController.cleanup()
    }
}

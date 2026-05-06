import Foundation

enum PlaybackTarget: Equatable {
    /// A web-embed target (e.g. YouTube iframe).
    case embedded(url: URL)

    /// A direct stream URL suitable for AVPlayer (e.g. mp4/m3u8).
    case direct(url: URL)

    /// Fallback when embedding/streaming is not viable; open externally (e.g. YouTube app/browser).
    case external(url: URL)
}

import Foundation

public enum PlaybackTarget: Equatable {
    /// An embedded player (e.g., YouTube embed) rendered in a WebView.
    case embedded(url: URL)
    /// Direct media stream playable by AVPlayer (HLS/MP4).
    case directStream(url: URL)
    /// Open externally in a browser or native app.
    case external(url: URL)
}

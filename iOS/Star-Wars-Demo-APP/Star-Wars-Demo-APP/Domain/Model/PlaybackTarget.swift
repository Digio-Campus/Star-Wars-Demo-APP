import Foundation

enum PlaybackTarget: Equatable {
    case vimeo(url: URL)
    case embedded(url: URL)
    // Direct stream (mp4/m3u8) playable by AVPlayer
    case direct(url: URL)
    // External URL (open in browser or external app)
    case external(url: URL)
}

import Foundation

enum PlaybackTarget: Equatable {
    case vimeo(url: URL)
    case embedded(url: URL)
}

import Foundation

enum VideoSource: Equatable {
    case YouTube(videoId: String, thumbnailUrl: URL?)
    case Vimeo(videoId: String)
    case Direct(url: URL)
}

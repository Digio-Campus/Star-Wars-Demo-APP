import Foundation

enum VideoSource: Equatable {
    case YouTube(videoId: String)
    case Vimeo(videoId: String)
    case Direct(url: URL)
}

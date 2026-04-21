import Foundation

struct VimeoVideo: Equatable, Sendable {
    let uri: String
    let link: String
    let name: String
    let playbackURL: URL?

    var videoId: String? {
        // Typical format: "/videos/123456789"
        let parts = uri.split(separator: "/")
        return parts.last.map(String.init)
    }
}

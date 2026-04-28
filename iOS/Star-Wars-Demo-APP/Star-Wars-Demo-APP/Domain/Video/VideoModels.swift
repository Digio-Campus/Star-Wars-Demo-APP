import Foundation

enum PlaybackTarget: Equatable {
    case embedded(URL)
    case directStream(URL)
    case external(URL)
}

struct VideoCandidate: Equatable {
    let provider: String
    let contentId: String
    let title: String
    let thumbnailURL: URL?
    let watchURL: URL?
}

enum VideoError: Error, Equatable {
    case authMissing
    case quotaExceeded
    case regionBlocked
    case notFound
    case network(Error)
    case providerUnsupported
    case unknown
}

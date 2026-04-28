import Foundation

struct VideoCandidate: Equatable, Sendable {
    let provider: String
    let contentId: String
    let title: String
    let watchUrl: URL
    let thumbnailUrl: URL?
    let embeddable: Bool
}

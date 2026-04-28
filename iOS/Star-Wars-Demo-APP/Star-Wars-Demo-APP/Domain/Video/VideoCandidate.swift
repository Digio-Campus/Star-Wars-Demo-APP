import Foundation

public struct VideoCandidate: Equatable {
    public let provider: String
    public let contentId: String
    public let title: String?
    public let watchURL: URL?
    public let thumbnailURL: URL?

    public init(provider: String, contentId: String, title: String? = nil, watchURL: URL? = nil, thumbnailURL: URL? = nil) {
        self.provider = provider
        self.contentId = contentId
        self.title = title
        self.watchURL = watchURL
        self.thumbnailURL = thumbnailURL
    }
}

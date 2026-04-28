import Foundation

actor YouTubeProvider: VideoProvider {
    private let apiKey: String?

    init(apiKey: String?) {
        self.apiKey = apiKey
    }

    func searchFirst(title: String) async throws -> VideoCandidate? {
        guard let key = apiKey, !key.isEmpty else {
            throw VideoError.authMissing
        }

        var components = URLComponents(string: "https://www.googleapis.com/youtube/v3/search")!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: title),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "1"),
            URLQueryItem(name: "videoEmbeddable", value: "true"),
            URLQueryItem(name: "key", value: key)
        ]

        guard let url = components.url else { return nil }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            if let http = response as? HTTPURLResponse, http.statusCode == 403 {
                throw VideoError.quotaExceeded
            }
            throw VideoError.unknown
        }

        struct SearchResponse: Decodable {
            let items: [Item]
            struct Item: Decodable {
                let id: Id
                let snippet: Snippet
                struct Id: Decodable { let videoId: String? }
                struct Snippet: Decodable {
                    let title: String
                    let thumbnails: Thumbnails?
                    struct Thumbnails: Decodable {
                        let `default`: Thumb?
                        let medium: Thumb?
                        let high: Thumb?
                        struct Thumb: Decodable { let url: String }
                    }
                }
            }
        }

        let decoder = JSONDecoder()
        let root = try decoder.decode(SearchResponse.self, from: data)
        guard let first = root.items.first, let videoId = first.id.videoId else { return nil }
        let snippet = first.snippet
        let thumbURLString = snippet.thumbnails?.medium?.url ?? snippet.thumbnails?.default?.url ?? snippet.thumbnails?.high?.url
        let thumbURL = thumbURLString.flatMap(URL.init)
        let watch = URL(string: "https://www.youtube.com/watch?v=\(videoId)")
        let candidate = VideoCandidate(provider: "youtube", contentId: videoId, title: snippet.title, thumbnailURL: thumbURL, watchURL: watch)
        return candidate
    }

    func resolvePlayback(for candidate: VideoCandidate) async throws -> PlaybackTarget? {
        guard !candidate.contentId.isEmpty else { return nil }
        guard let url = URL(string: "https://www.youtube.com/embed/\(candidate.contentId)") else { return nil }
        return .embedded(url)
    }
}

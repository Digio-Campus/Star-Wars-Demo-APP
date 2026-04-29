import Foundation
import os

enum YouTubeAPIError: LocalizedError {
    case missingApiKey
    case invalidURL
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .missingApiKey:
            return """
            Missing YouTube API key.

            Fix options:
            1) Create local (unversioned) iOS/Star-Wars-Demo-APP/Config.xcconfig with:
               YOUTUBE_API_KEY = <your_key>
               (Config.xcconfig maps it into the generated Info.plist key YOUTUBE_API_KEY)

            2) Or set an environment variable for the Run scheme:
               YOUTUBE_API_KEY = <your_key>
            """
        case .invalidURL:
            return "Invalid YouTube URL"
        case .invalidResponse:
            return "Invalid response from YouTube"
        case .httpStatus(let code):
            return "YouTube request failed (HTTP \(code))"
        }
    }
}

protocol YouTubeAPIKeyProviding {
    func apiKey() -> String?
}

struct BundleYouTubeAPIKeyProvider: YouTubeAPIKeyProviding {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Star-Wars-Demo-APP", category: "YouTube")

    func apiKey() -> String? {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "YOUTUBE_API_KEY") as? String {
            let key = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty else { logger.debug("YouTube key lookup: Info.plist key YOUTUBE_API_KEY is present but empty"); return nil }
            if key.contains("$(") { logger.debug("YouTube key lookup: Info.plist key looks unexpanded"); return nil }
            logger.debug("YouTube key lookup: using Info.plist YOUTUBE_API_KEY")
            return key
        }

        if let env = ProcessInfo.processInfo.environment["YOUTUBE_API_KEY"] {
            let key = env.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty else { logger.debug("YouTube key lookup: env var present but empty"); return nil }
            logger.debug("YouTube key lookup: using env YOUTUBE_API_KEY")
            return key
        }

        logger.debug("YouTube key lookup: missing")
        return nil
    }
}

final class YouTubeProvider {
    private let session: URLSession
    private let apiKeyProvider: YouTubeAPIKeyProviding
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Star-Wars-Demo-APP", category: "YouTube")
    private let baseURL = URL(string: "https://www.googleapis.com/youtube/v3/search")!

    init(session: URLSession = .shared, apiKeyProvider: YouTubeAPIKeyProviding = BundleYouTubeAPIKeyProvider()) {
        self.session = session
        self.apiKeyProvider = apiKeyProvider
    }

    // DTOs
    private struct SearchResponse: Decodable {
        struct Item: Decodable {
            struct Id: Decodable { let videoId: String? }
            struct Thumbnail: Decodable { let url: String? }
            struct Thumbnails: Decodable { let medium: Thumbnail?; let `default`: Thumbnail? }
            struct Snippet: Decodable { let title: String; let thumbnails: Thumbnails }
            let id: Id
            let snippet: Snippet
        }
        let items: [Item]
    }

    func searchFirst(title: String) async throws -> VideoCandidate? {
        guard let key = apiKeyProvider.apiKey() else { throw YouTubeAPIError.missingApiKey }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let query = title.contains("trailer") ? title : "\(title) trailer"
        components?.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "videoEmbeddable", value: "true"),
            URLQueryItem(name: "maxResults", value: "1"),
            URLQueryItem(name: "key", value: key)
        ]
        guard let url = components?.url else { throw YouTubeAPIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw YouTubeAPIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw YouTubeAPIError.httpStatus(http.statusCode) }

        let dto = try JSONDecoder().decode(SearchResponse.self, from: data)
        guard let first = dto.items.first, let videoId = first.id.videoId else { return nil }

        let watchUrl = URL(string: "https://youtu.be/\(videoId)")!
        let thumbnailStr = first.snippet.thumbnails.medium?.url ?? first.snippet.thumbnails.default?.url
        let thumbnailUrl = thumbnailStr.flatMap(URL.init)

        logger.debug("YouTube: found video \(videoId) for query \(title)")

        return VideoCandidate(
            provider: "youtube",
            contentId: videoId,
            title: first.snippet.title,
            watchUrl: watchUrl,
            thumbnailUrl: thumbnailUrl,
            embeddable: true
        )
    }
}

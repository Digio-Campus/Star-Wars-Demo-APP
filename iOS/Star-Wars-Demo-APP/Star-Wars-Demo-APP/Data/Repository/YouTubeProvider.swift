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
    private let videosURL = URL(string: "https://www.googleapis.com/youtube/v3/videos")!

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

    private struct VideosResponse: Decodable {
        struct Item: Decodable {
            struct Status: Decodable {
                let embeddable: Bool?
            }
            struct ContentDetails: Decodable {
                struct RegionRestriction: Decodable {
                    let blocked: [String]?
                    let allowed: [String]?
                }
                struct ContentRating: Decodable {
                    let ytRating: String?
                }
                let regionRestriction: RegionRestriction?
                let contentRating: ContentRating?
            }

            let id: String
            let status: Status?
            let contentDetails: ContentDetails?
        }

        let items: [Item]
    }

    func searchFirst(title: String) async throws -> VideoCandidate? {
        guard let key = apiKeyProvider.apiKey() else { throw YouTubeAPIError.missingApiKey }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseQuery = normalized.localizedCaseInsensitiveContains("star wars")
            ? normalized
            : "Star Wars \(normalized)"
        let withTrailer = baseQuery.localizedCaseInsensitiveContains("trailer") ? baseQuery : "\(baseQuery) trailer"
        // Prefer widely embeddable uploads.
        let query = "\(withTrailer) official"
        components?.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "videoEmbeddable", value: "true"),
            URLQueryItem(name: "videoSyndicated", value: "true"),
            URLQueryItem(name: "maxResults", value: "15"),
            URLQueryItem(name: "key", value: key)
        ]
        guard let url = components?.url else { throw YouTubeAPIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw YouTubeAPIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw YouTubeAPIError.httpStatus(http.statusCode) }

        let dto = try JSONDecoder().decode(SearchResponse.self, from: data)
        let candidates: [(videoId: String, title: String, thumbnailUrl: URL?)] = dto.items.compactMap {
            guard let videoId = $0.id.videoId else { return nil }
            let thumbnailStr = $0.snippet.thumbnails.medium?.url ?? $0.snippet.thumbnails.default?.url
            let thumbnailUrl = thumbnailStr.flatMap(URL.init)
            return (videoId: videoId, title: $0.snippet.title, thumbnailUrl: thumbnailUrl)
        }

        guard !candidates.isEmpty else { return nil }

        if let selected = try await pickBestEmbeddableVideo(candidates: candidates, apiKey: key) {
            let watchUrl = URL(string: "https://youtu.be/\(selected.videoId)")!
            logger.debug("YouTube: selected embeddable video \(selected.videoId) for query \(title)")
            return VideoCandidate(
                provider: "youtube",
                contentId: selected.videoId,
                title: selected.title,
                watchUrl: watchUrl,
                thumbnailUrl: selected.thumbnailUrl,
                embeddable: true
            )
        }

        // Fallback: we found results, but none are safe to embed (age/region/embeddable flags).
        let fallback = candidates[0]
        let watchUrl = URL(string: "https://youtu.be/\(fallback.videoId)")!
        logger.debug("YouTube: no embeddable candidates; falling back to external \(fallback.videoId) for query \(title)")

        return VideoCandidate(
            provider: "youtube",
            contentId: fallback.videoId,
            title: fallback.title,
            watchUrl: watchUrl,
            thumbnailUrl: fallback.thumbnailUrl,
            embeddable: false
        )
    }

    private func pickBestEmbeddableVideo(
        candidates: [(videoId: String, title: String, thumbnailUrl: URL?)],
        apiKey: String
    ) async throws -> (videoId: String, title: String, thumbnailUrl: URL?)? {
        let ids = candidates.map { $0.videoId }

        var components = URLComponents(url: videosURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "part", value: "status,contentDetails"),
            URLQueryItem(name: "id", value: ids.joined(separator: ",")),
            URLQueryItem(name: "key", value: apiKey)
        ]
        guard let url = components?.url else { throw YouTubeAPIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw YouTubeAPIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw YouTubeAPIError.httpStatus(http.statusCode) }

        let dto = try JSONDecoder().decode(VideosResponse.self, from: data)
        let detailsById = Dictionary(uniqueKeysWithValues: dto.items.map { ($0.id, $0) })

        let deviceRegion: String? = {
            if #available(iOS 16.0, *) {
                return Locale.current.region?.identifier
            }
            return Locale.current.regionCode
        }()

        for c in candidates {
            guard let details = detailsById[c.videoId] else { continue }

            // Be conservative: avoid videos that are clearly problematic for embeds.
            guard details.status?.embeddable == true else { continue }
            if details.contentDetails?.contentRating?.ytRating == "ytAgeRestricted" { continue }

            if let rr = details.contentDetails?.regionRestriction {
                if let blocked = rr.blocked, let r = deviceRegion, blocked.contains(r) {
                    continue
                }
                if let allowed = rr.allowed, let r = deviceRegion, !allowed.contains(r) {
                    continue
                }
            }

            return c
        }

        return nil
    }
}

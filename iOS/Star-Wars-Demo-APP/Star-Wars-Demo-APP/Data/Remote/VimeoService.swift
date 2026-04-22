import Foundation
import os

enum VimeoAPIError: LocalizedError {
    case missingAccessToken
    case invalidURL
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .missingAccessToken:
            return """
            Missing Vimeo access token.

            Fix options:
            1) Create local (unversioned) iOS/Star-Wars-Demo-APP/Config.xcconfig with:
               VIMEO_ACCESS_TOKEN = <your_token>
               (VimeoConfig.xcconfig maps it into the generated Info.plist key VIMEO_ACCESS_TOKEN)

            2) Or set an environment variable for the Run scheme:
               VIMEO_ACCESS_TOKEN = <your_token>
            """
        case .invalidURL:
            return "Invalid Vimeo URL"
        case .invalidResponse:
            return "Invalid response from Vimeo"
        case .httpStatus(let code):
            return "Vimeo request failed (HTTP \(code))"
        }
    }
}

protocol VimeoServiceProtocol {
    func searchVideos(query: String, perPage: Int) async throws -> [VimeoVideoDTO]
    func fetchPlaybackURL(videoURI: String) async throws -> URL?
}

protocol VimeoAccessTokenProviding {
    func accessToken() -> String?
}

struct BundleVimeoAccessTokenProvider: VimeoAccessTokenProviding {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Star-Wars-Demo-APP",
        category: "Vimeo"
    )

    func accessToken() -> String? {
        if let token = tokenFromInfoPlist() { return token }
        if let token = tokenFromEnvironment() { return token }
        return nil
    }

    private func tokenFromInfoPlist() -> String? {
        let raw = Bundle.main.object(forInfoDictionaryKey: "VIMEO_ACCESS_TOKEN") as? String
        guard let raw else {
            logger.debug("Vimeo token lookup: Info.plist key VIMEO_ACCESS_TOKEN is missing")
            return nil
        }

        let token = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty else {
            logger.debug("Vimeo token lookup: Info.plist key VIMEO_ACCESS_TOKEN is present but empty")
            return nil
        }

        // If the build setting wasn't applied, we can sometimes end up with an unexpanded placeholder.
        if token.contains("$(") {
            logger.debug("Vimeo token lookup: Info.plist key VIMEO_ACCESS_TOKEN looks unexpanded: \(self.redact(token))")
            return nil
        }

        logger.debug("Vimeo token lookup: using Info.plist VIMEO_ACCESS_TOKEN=\(self.redact(token))")
        return token
    }

    private func tokenFromEnvironment() -> String? {
        // Handy for local/dev automation via Xcode scheme env vars.
        let env = ProcessInfo.processInfo.environment["VIMEO_ACCESS_TOKEN"]
        guard let env else {
            logger.debug("Vimeo token lookup: env var VIMEO_ACCESS_TOKEN is missing")
            return nil
        }

        let token = env.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty else {
            logger.debug("Vimeo token lookup: env var VIMEO_ACCESS_TOKEN is present but empty")
            return nil
        }

        logger.debug("Vimeo token lookup: using env VIMEO_ACCESS_TOKEN=\(self.redact(token))")
        return token
    }

    private func redact(_ token: String) -> String {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        let count = trimmed.count
        guard count > 8 else { return "<redacted len=\(count)>" }

        let prefix = trimmed.prefix(4)
        let suffix = trimmed.suffix(4)
        return "\(prefix)…\(suffix) (len=\(count))"
    }
}

final class VimeoService: VimeoServiceProtocol {
    private let baseURL = URL(string: "https://api.vimeo.com")!
    private let session: URLSession
    private let tokenProvider: VimeoAccessTokenProviding

    init(
        session: URLSession = .shared,
        tokenProvider: VimeoAccessTokenProviding = BundleVimeoAccessTokenProvider()
    ) {
        self.session = session
        self.tokenProvider = tokenProvider
    }

    func searchVideos(query: String, perPage: Int = 1) async throws -> [VimeoVideoDTO] {
        guard let token = tokenProvider.accessToken() else { throw VimeoAPIError.missingAccessToken }

        var components = URLComponents(url: baseURL.appending(path: "videos"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        guard let url = components?.url else { throw VimeoAPIError.invalidURL }

        let response: VimeoSearchResponseDTO = try await request(url: url, token: token)
        return response.data
    }

    func fetchPlaybackURL(videoURI: String) async throws -> URL? {
        guard let token = tokenProvider.accessToken() else { throw VimeoAPIError.missingAccessToken }

        var path = videoURI
        if path.hasPrefix("/") { path.removeFirst() }

        var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "fields", value: "play")
        ]
        guard let url = components?.url else { throw VimeoAPIError.invalidURL }

        let dto: VimeoVideoPlaybackDTO = try await request(url: url, token: token)

        if let hls = dto.play?.hls?.link, let url = URL(string: hls) {
            return url
        }

        if let progressive = dto.play?.progressive, !progressive.isEmpty {
            let best = progressive.sorted { ($0.height ?? 0) > ($1.height ?? 0) }.first
            if let best, let url = URL(string: best.link) {
                return url
            }
        }

        return nil
    }

    private func request<T: Decodable>(url: URL, token: String) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw VimeoAPIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw VimeoAPIError.httpStatus(http.statusCode) }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

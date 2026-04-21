import Foundation

enum VimeoAPIError: LocalizedError {
    case missingAccessToken
    case invalidURL
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .missingAccessToken:
            return "Missing Vimeo access token"
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
    func accessToken() -> String? {
        let raw = Bundle.main.object(forInfoDictionaryKey: "VIMEO_ACCESS_TOKEN") as? String
        let token = raw?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let token, !token.isEmpty { return token }

        // Handy for local/dev automation.
        let env = ProcessInfo.processInfo.environment["VIMEO_ACCESS_TOKEN"]
        let envToken = env?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let envToken, !envToken.isEmpty { return envToken }

        return nil
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

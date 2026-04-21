import Foundation

actor VimeoRepositoryImpl: VimeoRepository {
    private struct CacheEntry {
        let value: VimeoVideo?
    }

    private let service: VimeoServiceProtocol
    private var cache: [String: CacheEntry] = [:]

    init(service: VimeoServiceProtocol) {
        self.service = service
    }

    func searchVimeoVideo(title: String) async throws -> VimeoVideo? {
        let key = normalize(title)
        if let cached = cache[key] { return cached.value }

        let videos = try await service.searchVideos(query: title, perPage: 1)
        guard let first = videos.first else {
            cache[key] = CacheEntry(value: nil)
            return nil
        }

        // Best-effort: if playback URL can't be retrieved, keep the metadata.
        let playbackURL: URL?
        do {
            playbackURL = try await service.fetchPlaybackURL(videoURI: first.uri)
        } catch {
            playbackURL = nil
        }

        let video = VimeoVideo(
            uri: first.uri,
            link: first.link,
            name: first.name,
            playbackURL: playbackURL
        )

        cache[key] = CacheEntry(value: video)
        return video
    }

    private func normalize(_ title: String) -> String {
        title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}

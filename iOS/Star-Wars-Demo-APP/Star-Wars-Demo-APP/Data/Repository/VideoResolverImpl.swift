import Foundation

actor VideoResolverImpl: VideoResolver {
    private let youtubeProvider: VideoProvider
    private let vimeoRepository: VimeoRepository

    init(youtubeProvider: VideoProvider, vimeoRepository: VimeoRepository) {
        self.youtubeProvider = youtubeProvider
        self.vimeoRepository = vimeoRepository
    }

    func resolveVideo(title: String) async throws -> (candidate: VideoCandidate, target: PlaybackTarget)? {
        // Try YouTube first
        do {
            if let candidate = try await youtubeProvider.searchFirst(title: title) {
                if let target = try await youtubeProvider.resolvePlayback(for: candidate) {
                    return (candidate, target)
                }
            }
        } catch {
            // ignore and fallback to Vimeo
        }

        // Fallback to Vimeo repository
        do {
            if let vimeo = try await vimeoRepository.searchVimeoVideo(title: title) {
                if let playback = vimeo.playbackURL {
                    let candidate = VideoCandidate(provider: "vimeo", contentId: vimeo.uri, title: vimeo.name, thumbnailURL: nil, watchURL: URL(string: vimeo.link))
                    return (candidate, .directStream(playback))
                } else if let linkURL = URL(string: vimeo.link) {
                    let candidate = VideoCandidate(provider: "vimeo", contentId: vimeo.uri, title: vimeo.name, thumbnailURL: nil, watchURL: linkURL)
                    return (candidate, .external(linkURL))
                }
            }
        } catch {
            // ignore
        }

        return nil
    }
}

import Foundation

final class VideoResolverImpl: VideoResolver {
    private let vimeoRepository: VimeoRepository
    private let youTubeProvider: YouTubeProvider

    init(vimeoRepository: VimeoRepository, youTubeProvider: YouTubeProvider) {
        self.vimeoRepository = vimeoRepository
        self.youTubeProvider = youTubeProvider
    }

    func resolve(title: String) async -> PlaybackTarget? {
        // Try Vimeo first (prefer direct playback URL)
        do {
            if let vimeo = try await vimeoRepository.searchVimeoVideo(title: title), let url = vimeo.playbackURL {
                return .vimeo(url: url)
            }
        } catch {
            // ignore and fallback to YouTube
        }

        // Try YouTube
        do {
            if let candidate = try await youTubeProvider.searchFirst(title: title), candidate.embeddable {
                if let embed = URL(string: "https://www.youtube.com/embed/\(candidate.contentId)?playsinline=1") {
                    return .embedded(url: embed)
                }
            }
        } catch {
            // ignore
        }

        return nil
    }
}

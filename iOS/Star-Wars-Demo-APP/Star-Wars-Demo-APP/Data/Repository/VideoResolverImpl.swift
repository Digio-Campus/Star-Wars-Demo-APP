import Foundation
import os

final class VideoResolverImpl: VideoResolver {
    private let vimeoRepository: VimeoRepository
    private let youTubeProvider: YouTubeProvider

    init(vimeoRepository: VimeoRepository, youTubeProvider: YouTubeProvider) {
        self.vimeoRepository = vimeoRepository
        self.youTubeProvider = youTubeProvider
    }

    func resolve(title: String) async throws -> PlaybackTarget? {
        var externalFallback: URL?

        // Prefer YouTube first; if it isn't embeddable, try Vimeo and only then fall back to opening YouTube externally.
        do {
            if let candidate = try await youTubeProvider.searchFirst(title: title) {
                externalFallback = candidate.watchUrl

                if candidate.embeddable,
                   let embed = URL(string: "https://www.youtube.com/embed/\(candidate.contentId)?playsinline=1&enablejsapi=1") {
                    return .embedded(url: embed)
                }
            }
        } catch {
            // Missing key / quota / networking errors: fall back to Vimeo.
        }

        // Vimeo direct stream (preferred for in-app playback)
        do {
            if let vimeo = try await vimeoRepository.searchVimeoVideo(title: title),
               let url = vimeo.playbackURL {
                return .direct(url: url)
            }
        } catch {
            // ignore and fall back
        }

        if let url = externalFallback {
            return .external(url: url)
        }

        return nil
    }
}

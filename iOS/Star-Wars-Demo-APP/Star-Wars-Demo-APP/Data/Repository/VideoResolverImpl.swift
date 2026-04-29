import Foundation
import os

final class VideoResolverImpl: VideoResolver {
    private let vimeoRepository: VimeoRepository
    private let youTubeProvider: YouTubeProvider
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Star-Wars-Demo-APP", category: "VideoResolver")

    init(vimeoRepository: VimeoRepository, youTubeProvider: YouTubeProvider) {
        self.vimeoRepository = vimeoRepository
        self.youTubeProvider = youTubeProvider
    }

    func resolve(title: String) async -> PlaybackTarget? {
        logger.debug("Resolving video for title: \(title)")

        // Debug fallback: check for environment variables
        if ProcessInfo.processInfo.environment["FORCE_USE_YOUTUBE"] == "true" {
            let videoId = ProcessInfo.processInfo.environment["FORCE_YOUTUBE_VIDEO_ID"] ?? "dQw4w9WgXcQ"
            logger.debug("Forcing YouTube resolution (DEBUG MODE) for ID: \(videoId)")
            if let embed = URL(string: "https://www.youtube.com/embed/\(videoId)?playsinline=1") {
                return .embedded(url: embed)
            }
        }

        // Try Vimeo first
        do {
            if let vimeo = try await vimeoRepository.searchVimeoVideo(title: title), let url = vimeo.playbackURL {
                logger.debug("Resolved via Vimeo: \(url)")
                return .vimeo(url: url)
            }
        } catch {
            logger.debug("Vimeo resolution failed: \(error.localizedDescription)")
        }

        // Try YouTube
        logger.debug("Attempting YouTube fallback for title: \(title)")
        do {
            if let candidate = try await youTubeProvider.searchFirst(title: title) {
                if candidate.embeddable, let embed = URL(string: "https://www.youtube.com/embed/\(candidate.contentId)?playsinline=1") {
                    logger.debug("Resolved via YouTube: \(candidate.contentId)")
                    return .embedded(url: embed)
                } else {
                    logger.debug("YouTube candidate found but not embeddable or invalid URL: \(candidate.contentId)")
                }
            } else {
                logger.debug("No YouTube candidate found for title: \(title)")
            }
        } catch {
            logger.error("YouTube resolution failed: \(error.localizedDescription)")
        }

        logger.debug("No video resolved for title: \(title)")
        return nil
    }
}

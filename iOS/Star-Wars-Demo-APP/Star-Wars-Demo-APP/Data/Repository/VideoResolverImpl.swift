import Foundation

actor VideoResolverImpl: VideoResolver {
    private let youtubeProvider: VideoProvider

    init(youtubeProvider: VideoProvider) {
        self.youtubeProvider = youtubeProvider
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
            // bubble up only if auth missing or quota? For now, swallow and treat as not found.
        }

        // No fallback providers available in this simplified implementation.
        return nil
    }
}

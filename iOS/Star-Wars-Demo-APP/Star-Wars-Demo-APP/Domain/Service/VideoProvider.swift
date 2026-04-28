import Foundation

protocol VideoProvider {
    func searchFirst(title: String) async throws -> VideoCandidate?
    func resolvePlayback(for candidate: VideoCandidate) async throws -> PlaybackTarget?
}

protocol VideoResolver {
    /// Resolve a title into a candidate and playback target. Returns nil if no provider could resolve.
    func resolveVideo(title: String) async throws -> (candidate: VideoCandidate, target: PlaybackTarget)?
}

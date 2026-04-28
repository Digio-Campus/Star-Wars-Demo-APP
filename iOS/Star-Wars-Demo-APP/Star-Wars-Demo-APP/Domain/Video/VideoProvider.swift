import Foundation

public protocol VideoProvider {
    var providerId: String { get }
    /// Search for the first candidate matching the query.
    func searchFirst(query: String, completion: @escaping (Result<VideoCandidate?, VideoError>) -> Void)
    /// Resolve a candidate into a PlaybackTarget (embedded/direct/external).
    func resolvePlayback(candidate: VideoCandidate, completion: @escaping (Result<PlaybackTarget, VideoError>) -> Void)
}

public protocol VideoResolver {
    /// Resolve a title into a PlaybackTarget, using configured providers + fallback policy.
    func resolve(title: String, completion: @escaping (Result<PlaybackTarget, VideoError>) -> Void)
}

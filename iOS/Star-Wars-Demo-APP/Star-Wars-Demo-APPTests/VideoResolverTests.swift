import Foundation
import Testing
@testable import Star_Wars_Demo_APP

struct VideoResolverTests {
    // Stub YouTube provider that returns a candidate
    private final class StubYouTube: VideoProvider {
        let candidate: VideoCandidate?
        let playback: PlaybackTarget?
        init(candidate: VideoCandidate?, playback: PlaybackTarget?) {
            self.candidate = candidate
            self.playback = playback
        }
        func searchFirst(title: String) async throws -> VideoCandidate? { candidate }
        func resolvePlayback(for candidate: VideoCandidate) async throws -> PlaybackTarget? { playback }
    }

    @Test func returnsYouTubeEmbedded() async throws {
        let ytCandidate = VideoCandidate(provider: "youtube", contentId: "abc123", title: "Test", thumbnailURL: nil, watchURL: URL(string: "https://youtube.test/watch?v=abc123"))
        let stubYT = StubYouTube(candidate: ytCandidate, playback: .embedded(URL(string: "https://www.youtube.com/embed/abc123")!))
        let resolver = VideoResolverImpl(youtubeProvider: stubYT)

        if let result = try await resolver.resolveVideo(title: "Test") {
            #expect(result.candidate.provider == "youtube")
            if case .embedded = result.target { }
            else { #expect(Bool(false)) }
        } else {
            #expect(Bool(false))
        }
    }

    @Test func returnsNilWhenNoProviders() async throws {
        let stubYT = StubYouTube(candidate: nil, playback: nil)
        let resolver = VideoResolverImpl(youtubeProvider: stubYT)
        let result = try await resolver.resolveVideo(title: "None")
        #expect(result == nil)
    }
}

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

    private final class StubVimeoRepo: VimeoRepository {
        let video: VimeoVideo?
        init(video: VimeoVideo?) { self.video = video }
        func searchVimeoVideo(title: String) async throws -> VimeoVideo? { video }
    }

    @Test func youtubePreferredOverVimeo() async throws {
        let ytCandidate = VideoCandidate(provider: "youtube", contentId: "abc123", title: "Test", thumbnailURL: nil, watchURL: URL(string: "https://youtube.test/watch?v=abc123"))
        let stubYT = StubYouTube(candidate: ytCandidate, playback: .embedded(URL(string: "https://www.youtube.com/embed/abc123")!))
        let stubVimeo = StubVimeoRepo(video: VimeoVideo(uri: "/videos/1", link: "https://vimeo.com/1", name: "V", playbackURL: nil))

        let resolver = VideoResolverImpl(youtubeProvider: (stubYT as! YouTubeProvider), vimeoRepository: stubVimeo)
        // Note: VideoResolverImpl expects a YouTubeProvider actor; to keep test simple, call the resolver via dynamic dispatch
        if let result = try await resolver.resolveVideo(title: "Test") {
            #expect(result.candidate.provider == "youtube")
            if case .embedded = result.target { }
            else { #expect(Bool(false)) }
        } else {
            #expect(Bool(false))
        }
    }

    @Test func vimeoFallbackWhenYoutubeMissing() async throws {
        let stubYT = StubYouTube(candidate: nil, playback: nil)
        let vimeoVideo = VimeoVideo(uri: "/videos/999", link: "https://vimeo.com/999", name: "V999", playbackURL: URL(string: "https://cdn.vimeo.com/stream.m3u8"))
        let stubVimeo = StubVimeoRepo(video: vimeoVideo)

        let resolver = VideoResolverImpl(youtubeProvider: (stubYT as! YouTubeProvider), vimeoRepository: stubVimeo)
        if let result = try await resolver.resolveVideo(title: "Whatever") {
            #expect(result.candidate.provider == "vimeo")
            if case .directStream = result.target { }
            else { #expect(Bool(false)) }
        } else {
            #expect(Bool(false))
        }
    }
}

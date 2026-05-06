import Foundation
import Testing
@testable import Star_Wars_Demo_APP

struct VideoSourceTests {

    @Test func playbackTarget_toVideoSource_mapsYouTubeAndVimeo() {
        let ytURL = URL(string: "https://www.youtube.com/embed/abc123?playsinline=1")!
        let pt1 = PlaybackTarget.embedded(url: ytURL)
        let vs1 = pt1.toVideoSource()
        #expect({
            if case .YouTube(let id) = vs1 { return id == "abc123" } else { return false }
        }())

        let directURL = URL(string: "https://example.com/video.mp4")!
        let pt2 = PlaybackTarget.direct(url: directURL)
        let vs2 = pt2.toVideoSource()
        #expect({
            if case .Direct(let url) = vs2 { return url == directURL } else { return false }
        }())
    }
}

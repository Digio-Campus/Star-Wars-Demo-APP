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

        let vimeoURL = URL(string: "https://player.vimeo.com/video/987654")!
        let pt2 = PlaybackTarget.vimeo(url: vimeoURL)
        let vs2 = pt2.toVideoSource()
        #expect({
            if case .Vimeo(let id) = vs2 { return id == "987654" } else { return false }
        }())
    }
}

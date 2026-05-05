import Foundation
import Testing
@testable import Star_Wars_Demo_APP

struct IOSTrailerPlayerTests {

    @Test func iOSTrailerPlayer_lifecycle_noCrash() {
        let vc = IOSTrailerPlayer()
        vc.load(source: .Direct(url: URL(string: "https://example.com/video.mp4")!))
        vc.play()
        vc.pause()
        vc.enableCasting()
        vc.cleanup()
        #expect(true)
    }
}

import Foundation
import UIKit

@MainActor
protocol TrailerPlayer: AnyObject {
    func load(source: VideoSource)
    func play()
    func pause()
    func cleanup()
    func enableCasting()
}

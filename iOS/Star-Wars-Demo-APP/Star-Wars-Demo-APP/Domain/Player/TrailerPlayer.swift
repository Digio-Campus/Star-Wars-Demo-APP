import Foundation
import UIKit

protocol TrailerPlayer: AnyObject {
    func load(source: VideoSource)
    func play()
    func pause()
    func release()
    func enableCasting()
}

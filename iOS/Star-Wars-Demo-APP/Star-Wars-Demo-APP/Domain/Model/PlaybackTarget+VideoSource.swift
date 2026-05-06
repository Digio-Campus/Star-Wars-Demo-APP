import Foundation

extension PlaybackTarget {
    func toVideoSource() -> VideoSource {
        switch self {
        case .direct(let url):
            return .Direct(url: url)

        case .embedded(let url):
            let comps = url.pathComponents
            if let embedIndex = comps.firstIndex(of: "embed"), embedIndex + 1 < comps.count {
                let id = comps[embedIndex + 1]
                return .YouTube(videoId: id)
            }
            if let v = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "v" })?.value {
                return .YouTube(videoId: v)
            }
            return .Direct(url: url)

        case .external(let url):
            // This is not meant to be played in-app; UI should open the URL externally.
            return .Direct(url: url)
        }
    }
}

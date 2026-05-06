import Foundation

extension PlaybackTarget {
    func toVideoSource() -> VideoSource {
        switch self {
        case .vimeo(let url):
            let last = url.deletingPathExtension().lastPathComponent
            if !last.isEmpty {
                return .Vimeo(videoId: last)
            }
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
        case .direct(let url):
            return .Direct(url: url)
        case .external(let url):
            return .Direct(url: url)
        }
    }
}

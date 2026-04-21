import Foundation

struct VimeoSearchResponseDTO: Decodable {
    let data: [VimeoVideoDTO]
}

struct VimeoVideoDTO: Decodable {
    let uri: String
    let link: String
    let name: String
}

struct VimeoVideoPlaybackDTO: Decodable {
    struct PlayDTO: Decodable {
        struct HlsDTO: Decodable {
            let link: String?
        }

        struct ProgressiveDTO: Decodable {
            let link: String
            let height: Int?
        }

        let hls: HlsDTO?
        let progressive: [ProgressiveDTO]?
    }

    let play: PlayDTO?
}

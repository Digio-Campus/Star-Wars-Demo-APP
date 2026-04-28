import Foundation
import Testing
@testable import Star_Wars_Demo_APP

struct YouTubeParsingTests {

    @Test func youtubeResponse_mapsToVideoCandidate() throws {
        let json = #"""
        {
          "items": [
            {
              "id": { "videoId": "abc123" },
              "snippet": {
                "title": "Test video",
                "thumbnails": {
                  "medium": { "url": "https://img.example/1.jpg" }
                }
              }
            }
          ]
        }
        ""#

        struct Thumbnail: Decodable { let url: String? }
        struct Thumbnails: Decodable { let medium: Thumbnail?; let `default`: Thumbnail? }
        struct Snippet: Decodable { let title: String; let thumbnails: Thumbnails }
        struct Id: Decodable { let videoId: String? }
        struct Item: Decodable { let id: Id; let snippet: Snippet }
        struct ResponseDTO: Decodable { let items: [Item] }

        let dto = try JSONDecoder().decode(ResponseDTO.self, from: Data(json.utf8))
        guard let first = dto.items.first, let videoId = first.id.videoId else { throw NSError(domain: "test", code: 1) }

        let candidate = VideoCandidate(
            provider: "youtube",
            contentId: videoId,
            title: first.snippet.title,
            watchUrl: URL(string: "https://youtu.be/\(videoId)")!,
            thumbnailUrl: first.snippet.thumbnails.medium?.url.flatMap(URL.init),
            embeddable: true
        )

        #expect(candidate.contentId == "abc123")
        #expect(candidate.title == "Test video")
        #expect(candidate.watchUrl.absoluteString == "https://youtu.be/abc123")
        #expect(candidate.thumbnailUrl?.absoluteString == "https://img.example/1.jpg")
    }
}

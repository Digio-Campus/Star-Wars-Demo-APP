import Foundation

struct Film: Identifiable, Equatable, Hashable {
    let id: Int
    let title: String
    let episodeId: Int
    let openingCrawl: String
    let director: String
    let producer: String
    let releaseDate: String
    let charactersCount: Int
    let planetsCount: Int
    let starshipsCount: Int
    let vehiclesCount: Int
    let speciesCount: Int
}

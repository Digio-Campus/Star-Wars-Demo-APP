import Foundation

struct FilmDTO: Decodable {
    let title: String
    let episodeId: Int
    let openingCrawl: String
    let director: String
    let producer: String
    let releaseDate: String
    let characters: [String]
    let planets: [String]
    let starships: [String]
    let vehicles: [String]
    let species: [String]
    let url: String

    enum CodingKeys: String, CodingKey {
        case title, director, producer, characters, planets, starships, vehicles, species, url
        case episodeId = "episode_id"
        case openingCrawl = "opening_crawl"
        case releaseDate = "release_date"
    }
}

extension FilmDTO {
    func toDomain() -> Film {
        let id = url.split(separator: "/").last.flatMap { Int($0) } ?? 0
        return Film(
            id: id,
            title: title,
            episodeId: episodeId,
            openingCrawl: openingCrawl,
            director: director,
            producer: producer,
            releaseDate: releaseDate,
            charactersCount: characters.count,
            planetsCount: planets.count,
            starshipsCount: starships.count,
            vehiclesCount: vehicles.count,
            speciesCount: species.count
        )
    }
}

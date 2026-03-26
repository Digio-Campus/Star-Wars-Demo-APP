import Foundation
import SwiftData

@Model
final class FilmSwiftDataModel {
    @Attribute(.unique) var id: Int
    var title: String
    var episodeId: Int
    var openingCrawl: String
    var director: String
    var producer: String
    var releaseDate: String
    var charactersCount: Int
    var planetsCount: Int
    var starshipsCount: Int
    var vehiclesCount: Int
    var speciesCount: Int
    var lastUpdated: Date

    init(
        id: Int,
        title: String,
        episodeId: Int,
        openingCrawl: String,
        director: String,
        producer: String,
        releaseDate: String,
        charactersCount: Int,
        planetsCount: Int,
        starshipsCount: Int,
        vehiclesCount: Int,
        speciesCount: Int,
        lastUpdated: Date
    ) {
        self.id = id
        self.title = title
        self.episodeId = episodeId
        self.openingCrawl = openingCrawl
        self.director = director
        self.producer = producer
        self.releaseDate = releaseDate
        self.charactersCount = charactersCount
        self.planetsCount = planetsCount
        self.starshipsCount = starshipsCount
        self.vehiclesCount = vehiclesCount
        self.speciesCount = speciesCount
        self.lastUpdated = lastUpdated
    }
}

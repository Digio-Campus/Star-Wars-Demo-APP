import Foundation
import SwiftData

@Model
final class StarshipSwiftDataModel {
    @Attribute(.unique) var id: Int
    var name: String
    var model: String
    var manufacturer: String
    var starshipClass: String
    var crew: String
    var passengers: String
    var costInCredits: String
    var hyperdriveRating: String
    var filmsCount: Int
    var lastUpdated: Date

    init(
        id: Int,
        name: String,
        model: String,
        manufacturer: String,
        starshipClass: String,
        crew: String,
        passengers: String,
        costInCredits: String,
        hyperdriveRating: String,
        filmsCount: Int,
        lastUpdated: Date
    ) {
        self.id = id
        self.name = name
        self.model = model
        self.manufacturer = manufacturer
        self.starshipClass = starshipClass
        self.crew = crew
        self.passengers = passengers
        self.costInCredits = costInCredits
        self.hyperdriveRating = hyperdriveRating
        self.filmsCount = filmsCount
        self.lastUpdated = lastUpdated
    }
}

import Foundation
import SwiftData

@Model
final class PersonSwiftDataModel {
    @Attribute(.unique) var id: Int
    var name: String
    var height: String
    var mass: String
    var gender: String
    var birthYear: String
    var homeworldURL: String
    var filmsCount: Int
    var starshipsCount: Int
    var vehiclesCount: Int
    var speciesCount: Int
    var lastUpdated: Date

    init(
        id: Int,
        name: String,
        height: String,
        mass: String,
        gender: String,
        birthYear: String,
        homeworldURL: String,
        filmsCount: Int,
        starshipsCount: Int,
        vehiclesCount: Int,
        speciesCount: Int,
        lastUpdated: Date
    ) {
        self.id = id
        self.name = name
        self.height = height
        self.mass = mass
        self.gender = gender
        self.birthYear = birthYear
        self.homeworldURL = homeworldURL
        self.filmsCount = filmsCount
        self.starshipsCount = starshipsCount
        self.vehiclesCount = vehiclesCount
        self.speciesCount = speciesCount
        self.lastUpdated = lastUpdated
    }
}

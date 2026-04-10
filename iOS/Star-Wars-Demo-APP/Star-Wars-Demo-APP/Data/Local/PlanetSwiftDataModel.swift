import Foundation
import SwiftData

@Model
final class PlanetSwiftDataModel {
    @Attribute(.unique) var id: Int
    var name: String
    var climate: String
    var terrain: String
    var population: String
    var diameter: String
    var gravity: String
    var residentsCount: Int
    var filmsCount: Int
    var lastUpdated: Date

    init(
        id: Int,
        name: String,
        climate: String,
        terrain: String,
        population: String,
        diameter: String,
        gravity: String,
        residentsCount: Int,
        filmsCount: Int,
        lastUpdated: Date
    ) {
        self.id = id
        self.name = name
        self.climate = climate
        self.terrain = terrain
        self.population = population
        self.diameter = diameter
        self.gravity = gravity
        self.residentsCount = residentsCount
        self.filmsCount = filmsCount
        self.lastUpdated = lastUpdated
    }
}

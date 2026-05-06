import Foundation

struct PlanetDTO: Decodable {
    let name: String
    let rotationPeriod: String
    let orbitalPeriod: String
    let diameter: String
    let climate: String
    let gravity: String
    let terrain: String
    let surfaceWater: String
    let population: String
    let residents: [String]
    let films: [String]
    let url: String

    enum CodingKeys: String, CodingKey {
        case name, diameter, climate, gravity, terrain, population, residents, films, url
        case rotationPeriod = "rotation_period"
        case orbitalPeriod = "orbital_period"
        case surfaceWater = "surface_water"
    }
}

extension PlanetDTO {
    func toDomain() -> Planet {
        let id = url.split(separator: "/").last.flatMap { Int($0) } ?? 0
        return Planet(
            id: id,
            name: name,
            climate: climate,
            terrain: terrain,
            population: population,
            diameter: diameter,
            gravity: gravity,
            residentsCount: residents.count,
            filmsCount: films.count
        )
    }
}

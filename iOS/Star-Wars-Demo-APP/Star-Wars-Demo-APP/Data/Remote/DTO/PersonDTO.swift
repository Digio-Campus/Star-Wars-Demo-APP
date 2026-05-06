import Foundation

struct PersonDTO: Decodable {
    let name: String
    let height: String
    let mass: String
    let hairColor: String
    let skinColor: String
    let eyeColor: String
    let birthYear: String
    let gender: String
    let homeworld: String
    let films: [String]
    let species: [String]
    let vehicles: [String]
    let starships: [String]
    let url: String

    enum CodingKeys: String, CodingKey {
        case name, height, mass, gender, homeworld, films, species, vehicles, starships, url
        case hairColor = "hair_color"
        case skinColor = "skin_color"
        case eyeColor = "eye_color"
        case birthYear = "birth_year"
    }
}

extension PersonDTO {
    func toDomain() -> Person {
        let id = url.split(separator: "/").last(where: { !$0.isEmpty }).flatMap { Int($0) } ?? 0
        return Person(
            id: id,
            name: name,
            height: height,
            mass: mass,
            gender: gender,
            birthYear: birthYear,
            homeworldURL: homeworld,
            filmsCount: films.count,
            starshipsCount: starships.count,
            vehiclesCount: vehicles.count,
            speciesCount: species.count
        )
    }
}

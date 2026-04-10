import Foundation

struct StarshipDTO: Decodable {
    let name: String
    let model: String
    let manufacturer: String
    let costInCredits: String
    let length: String
    let maxAtmospheringSpeed: String
    let crew: String
    let passengers: String
    let cargoCapacity: String
    let consumables: String
    let hyperdriveRating: String
    let mglt: String
    let starshipClass: String
    let films: [String]
    let url: String

    enum CodingKeys: String, CodingKey {
        case name, model, manufacturer, length, crew, passengers, consumables, films, url
        case costInCredits = "cost_in_credits"
        case maxAtmospheringSpeed = "max_atmosphering_speed"
        case cargoCapacity = "cargo_capacity"
        case hyperdriveRating = "hyperdrive_rating"
        case mglt = "MGLT"
        case starshipClass = "starship_class"
    }
}

extension StarshipDTO {
    func toDomain() -> Starship {
        let id = url.split(separator: "/").last.flatMap { Int($0) } ?? 0
        return Starship(
            id: id,
            name: name,
            model: model,
            manufacturer: manufacturer,
            starshipClass: starshipClass,
            crew: crew,
            passengers: passengers,
            costInCredits: costInCredits,
            hyperdriveRating: hyperdriveRating,
            filmsCount: films.count
        )
    }
}

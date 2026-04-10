import Foundation

struct Starship: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let model: String
    let manufacturer: String
    let starshipClass: String
    let crew: String
    let passengers: String
    let costInCredits: String
    let hyperdriveRating: String
    let filmsCount: Int
}

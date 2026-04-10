import Foundation

struct Person: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let height: String
    let mass: String
    let gender: String
    let birthYear: String
    let homeworldURL: String
    let filmsCount: Int
    let starshipsCount: Int
    let vehiclesCount: Int
    let speciesCount: Int
}

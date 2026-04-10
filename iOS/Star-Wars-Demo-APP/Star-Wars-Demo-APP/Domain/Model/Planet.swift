import Foundation

struct Planet: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let climate: String
    let terrain: String
    let population: String
    let diameter: String
    let gravity: String
    let residentsCount: Int
    let filmsCount: Int
}

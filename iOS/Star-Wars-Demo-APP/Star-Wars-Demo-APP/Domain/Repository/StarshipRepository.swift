import Foundation

protocol StarshipRepository {
    /// Cache-first read. Does not trigger network.
    func getStarships() async -> Result<[Starship], Error>

    /// Always hits network, updates local cache, returns fresh data.
    func refreshStarships() async -> Result<[Starship], Error>

    func getStarshipById(_ id: Int) async -> Result<Starship, Error>
    func refreshStarship(id: Int) async -> Result<Starship, Error>

    func deleteItem(id: Int) async -> Result<Void, Error>
}

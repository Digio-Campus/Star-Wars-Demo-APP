import Foundation

protocol PlanetRepository {
    /// Cache-first read. Does not trigger network.
    func getPlanets() async -> Result<[Planet], Error>

    /// Always hits network, updates local cache, returns fresh data.
    func refreshPlanets() async -> Result<[Planet], Error>

    func getPlanetById(_ id: Int) async -> Result<Planet, Error>
    func refreshPlanet(id: Int) async -> Result<Planet, Error>
}

import Foundation

final class PlanetRepositoryImpl: PlanetRepository {
    private let api: StarWarsAPIServiceProtocol
    private let local: PlanetLocalDataSource

    init(api: StarWarsAPIServiceProtocol, local: PlanetLocalDataSource) {
        self.api = api
        self.local = local
    }

    func getPlanets() async -> Result<[Planet], Error> {
        do {
            let models = try await local.fetchAllPlanets()
            let planets = models.map { $0.toDomain() }.sorted { $0.name < $1.name }
            return .success(planets)
        } catch {
            return .failure(error)
        }
    }

    func refreshPlanets() async -> Result<[Planet], Error> {
        do {
            let dtos = try await api.fetchPlanets()
            let planets = dtos.map { $0.toDomain() }.sorted { $0.name < $1.name }
            try await local.upsertPlanets(planets)
            return .success(planets)
        } catch {
            return .failure(error)
        }
    }

    func getPlanetById(_ id: Int) async -> Result<Planet, Error> {
        do {
            if let model = try await local.fetchPlanet(byId: id) {
                return .success(model.toDomain())
            }

            let dto = try await api.fetchPlanet(id: id)
            let planet = dto.toDomain()
            try await local.upsertPlanets([planet])
            return .success(planet)
        } catch {
            return .failure(error)
        }
    }

    func refreshPlanet(id: Int) async -> Result<Planet, Error> {
        do {
            let dto = try await api.fetchPlanet(id: id)
            let planet = dto.toDomain()
            try await local.upsertPlanets([planet])
            return .success(planet)
        } catch {
            return .failure(error)
        }
    }
}

private extension PlanetSwiftDataModel {
    func toDomain() -> Planet {
        Planet(
            id: id,
            name: name,
            climate: climate,
            terrain: terrain,
            population: population,
            diameter: diameter,
            gravity: gravity,
            residentsCount: residentsCount,
            filmsCount: filmsCount
        )
    }
}

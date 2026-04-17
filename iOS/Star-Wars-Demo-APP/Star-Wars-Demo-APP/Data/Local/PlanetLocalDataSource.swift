import Foundation
import SwiftData

actor PlanetLocalDataSource {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    private func makeContext() -> ModelContext {
        ModelContext(container)
    }

    func fetchAllPlanets() throws -> [PlanetSwiftDataModel] {
        let context = makeContext()
        return try context.fetch(FetchDescriptor<PlanetSwiftDataModel>())
    }

    func fetchPlanet(byId id: Int) throws -> PlanetSwiftDataModel? {
        let context = makeContext()
        let descriptor = FetchDescriptor<PlanetSwiftDataModel>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first
    }

    func upsertPlanets(_ planets: [Planet]) throws {
        let context = makeContext()
        for planet in planets {
            let planetId = planet.id
            let existing = try context.fetch(
                FetchDescriptor<PlanetSwiftDataModel>(predicate: #Predicate { $0.id == planetId })
            ).first

            if let existing {
                existing.name = planet.name
                existing.climate = planet.climate
                existing.terrain = planet.terrain
                existing.population = planet.population
                existing.diameter = planet.diameter
                existing.gravity = planet.gravity
                existing.residentsCount = planet.residentsCount
                existing.filmsCount = planet.filmsCount
                existing.lastUpdated = .now
            } else {
                let model = PlanetSwiftDataModel(
                    id: planet.id,
                    name: planet.name,
                    climate: planet.climate,
                    terrain: planet.terrain,
                    population: planet.population,
                    diameter: planet.diameter,
                    gravity: planet.gravity,
                    residentsCount: planet.residentsCount,
                    filmsCount: planet.filmsCount,
                    lastUpdated: .now
                )
                context.insert(model)
            }
        }
        try context.save()
    }

    func deletePlanet(id: Int) throws {
        let context = makeContext()
        let descriptor = FetchDescriptor<PlanetSwiftDataModel>(predicate: #Predicate { $0.id == id })
        guard let model = try context.fetch(descriptor).first else { return }
        context.delete(model)
        try context.save()
    }

    func deleteAllPlanets() throws {
        let context = makeContext()
        try context.delete(model: PlanetSwiftDataModel.self)
        try context.save()
    }

    func planetsCount() throws -> Int {
        let context = makeContext()
        return try context.fetchCount(FetchDescriptor<PlanetSwiftDataModel>())
    }
}

import Foundation
import SwiftData

actor StarshipLocalDataSource {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    private func makeContext() -> ModelContext {
        ModelContext(container)
    }

    func fetchAllStarships() throws -> [StarshipSwiftDataModel] {
        let context = makeContext()
        return try context.fetch(FetchDescriptor<StarshipSwiftDataModel>())
    }

    func fetchStarship(byId id: Int) throws -> StarshipSwiftDataModel? {
        let context = makeContext()
        let descriptor = FetchDescriptor<StarshipSwiftDataModel>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first
    }

    func upsertStarships(_ starships: [Starship]) throws {
        let context = makeContext()
        for starship in starships {
            let starshipId = starship.id
            let existing = try context.fetch(
                FetchDescriptor<StarshipSwiftDataModel>(predicate: #Predicate { $0.id == starshipId })
            ).first

            if let existing {
                existing.name = starship.name
                existing.model = starship.model
                existing.manufacturer = starship.manufacturer
                existing.starshipClass = starship.starshipClass
                existing.crew = starship.crew
                existing.passengers = starship.passengers
                existing.costInCredits = starship.costInCredits
                existing.hyperdriveRating = starship.hyperdriveRating
                existing.filmsCount = starship.filmsCount
                existing.lastUpdated = .now
            } else {
                let model = StarshipSwiftDataModel(
                    id: starship.id,
                    name: starship.name,
                    model: starship.model,
                    manufacturer: starship.manufacturer,
                    starshipClass: starship.starshipClass,
                    crew: starship.crew,
                    passengers: starship.passengers,
                    costInCredits: starship.costInCredits,
                    hyperdriveRating: starship.hyperdriveRating,
                    filmsCount: starship.filmsCount,
                    lastUpdated: .now
                )
                context.insert(model)
            }
        }
        try context.save()
    }

    func deleteAllStarships() throws {
        let context = makeContext()
        try context.delete(model: StarshipSwiftDataModel.self)
        try context.save()
    }

    func starshipsCount() throws -> Int {
        let context = makeContext()
        return try context.fetchCount(FetchDescriptor<StarshipSwiftDataModel>())
    }
}

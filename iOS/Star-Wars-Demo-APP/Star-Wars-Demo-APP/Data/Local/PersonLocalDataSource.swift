import Foundation
import SwiftData

actor PersonLocalDataSource {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    private func makeContext() -> ModelContext {
        ModelContext(container)
    }

    func fetchAllPeople() throws -> [PersonSwiftDataModel] {
        let context = makeContext()
        return try context.fetch(FetchDescriptor<PersonSwiftDataModel>())
    }

    func fetchPerson(byId id: Int) throws -> PersonSwiftDataModel? {
        let context = makeContext()
        let descriptor = FetchDescriptor<PersonSwiftDataModel>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first
    }

    func upsertPeople(_ people: [Person]) throws {
        let context = makeContext()
        for person in people {
            let personId = person.id
            let existing = try context.fetch(
                FetchDescriptor<PersonSwiftDataModel>(predicate: #Predicate { $0.id == personId })
            ).first

            if let existing {
                existing.name = person.name
                existing.height = person.height
                existing.mass = person.mass
                existing.gender = person.gender
                existing.birthYear = person.birthYear
                existing.homeworldURL = person.homeworldURL
                existing.filmsCount = person.filmsCount
                existing.starshipsCount = person.starshipsCount
                existing.vehiclesCount = person.vehiclesCount
                existing.speciesCount = person.speciesCount
                existing.lastUpdated = .now
            } else {
                let model = PersonSwiftDataModel(
                    id: person.id,
                    name: person.name,
                    height: person.height,
                    mass: person.mass,
                    gender: person.gender,
                    birthYear: person.birthYear,
                    homeworldURL: person.homeworldURL,
                    filmsCount: person.filmsCount,
                    starshipsCount: person.starshipsCount,
                    vehiclesCount: person.vehiclesCount,
                    speciesCount: person.speciesCount,
                    lastUpdated: .now
                )
                context.insert(model)
            }
        }
        try context.save()
    }

    func deletePerson(id: Int) throws {
        let context = makeContext()
        let descriptor = FetchDescriptor<PersonSwiftDataModel>(predicate: #Predicate { $0.id == id })
        guard let model = try context.fetch(descriptor).first else { return }
        context.delete(model)
        try context.save()
    }

    func deleteAllPeople() throws {
        let context = makeContext()
        try context.delete(model: PersonSwiftDataModel.self)
        try context.save()
    }

    func peopleCount() throws -> Int {
        let context = makeContext()
        return try context.fetchCount(FetchDescriptor<PersonSwiftDataModel>())
    }
}

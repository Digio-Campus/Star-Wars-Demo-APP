import Foundation

final class PersonRepositoryImpl: PersonRepository {
    private let api: StarWarsAPIServiceProtocol
    private let local: PersonLocalDataSource

    init(api: StarWarsAPIServiceProtocol, local: PersonLocalDataSource) {
        self.api = api
        self.local = local
    }

    func getPeople() async -> Result<[Person], Error> {
        do {
            let models = try await local.fetchAllPeople()
            let people = models.map { $0.toDomain() }.sorted { $0.name < $1.name }
            return .success(people)
        } catch {
            return .failure(error)
        }
    }

    func refreshPeople() async -> Result<[Person], Error> {
        do {
            let dtos = try await api.fetchPeople()
            let people = dtos.map { $0.toDomain() }.sorted { $0.name < $1.name }
            try await local.upsertPeople(people)
            return .success(people)
        } catch {
            return .failure(error)
        }
    }

    func getPersonById(_ id: Int) async -> Result<Person, Error> {
        do {
            if let model = try await local.fetchPerson(byId: id) {
                return .success(model.toDomain())
            }

            let dto = try await api.fetchPerson(id: id)
            let person = dto.toDomain()
            try await local.upsertPeople([person])
            return .success(person)
        } catch {
            return .failure(error)
        }
    }

    func refreshPerson(id: Int) async -> Result<Person, Error> {
        do {
            let dto = try await api.fetchPerson(id: id)
            let person = dto.toDomain()
            try await local.upsertPeople([person])
            return .success(person)
        } catch {
            return .failure(error)
        }
    }

    func deleteItem(id: Int) async -> Result<Void, Error> {
        do {
            try await local.deletePerson(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

private extension PersonSwiftDataModel {
    func toDomain() -> Person {
        Person(
            id: id,
            name: name,
            height: height,
            mass: mass,
            gender: gender,
            birthYear: birthYear,
            homeworldURL: homeworldURL,
            filmsCount: filmsCount,
            starshipsCount: starshipsCount,
            vehiclesCount: vehiclesCount,
            speciesCount: speciesCount
        )
    }
}

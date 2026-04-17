import Foundation

final class StarshipRepositoryImpl: StarshipRepository {
    private let api: StarWarsAPIServiceProtocol
    private let local: StarshipLocalDataSource

    init(api: StarWarsAPIServiceProtocol, local: StarshipLocalDataSource) {
        self.api = api
        self.local = local
    }

    func getStarships() async -> Result<[Starship], Error> {
        do {
            let models = try await local.fetchAllStarships()
            let starships = models.map { $0.toDomain() }.sorted { $0.name < $1.name }
            return .success(starships)
        } catch {
            return .failure(error)
        }
    }

    func refreshStarships() async -> Result<[Starship], Error> {
        do {
            let dtos = try await api.fetchStarships()
            let starships = dtos.map { $0.toDomain() }.sorted { $0.name < $1.name }
            try await local.upsertStarships(starships)
            return .success(starships)
        } catch {
            return .failure(error)
        }
    }

    func getStarshipById(_ id: Int) async -> Result<Starship, Error> {
        do {
            if let model = try await local.fetchStarship(byId: id) {
                return .success(model.toDomain())
            }

            let dto = try await api.fetchStarship(id: id)
            let starship = dto.toDomain()
            try await local.upsertStarships([starship])
            return .success(starship)
        } catch {
            return .failure(error)
        }
    }

    func refreshStarship(id: Int) async -> Result<Starship, Error> {
        do {
            let dto = try await api.fetchStarship(id: id)
            let starship = dto.toDomain()
            try await local.upsertStarships([starship])
            return .success(starship)
        } catch {
            return .failure(error)
        }
    }

    func deleteItem(id: Int) async -> Result<Void, Error> {
        do {
            try await local.deleteStarship(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

private extension StarshipSwiftDataModel {
    func toDomain() -> Starship {
        Starship(
            id: id,
            name: name,
            model: model,
            manufacturer: manufacturer,
            starshipClass: starshipClass,
            crew: crew,
            passengers: passengers,
            costInCredits: costInCredits,
            hyperdriveRating: hyperdriveRating,
            filmsCount: filmsCount
        )
    }
}

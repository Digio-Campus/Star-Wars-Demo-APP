import Foundation

final class FilmRepositoryImpl: FilmRepository {
    private let api: StarWarsAPIServiceProtocol
    private let local: FilmLocalDataSource

    init(api: StarWarsAPIServiceProtocol, local: FilmLocalDataSource) {
        self.api = api
        self.local = local
    }

    func getFilms() async -> Result<[Film], Error> {
        do {
            let models = try await local.fetchAllFilms()
            let films = models.map { $0.toDomain() }.sorted { $0.episodeId < $1.episodeId }
            return .success(films)
        } catch {
            return .failure(error)
        }
    }

    func refreshFilms() async -> Result<[Film], Error> {
        do {
            let dtos = try await api.fetchFilms()
            let films = dtos.map { $0.toDomain() }.sorted { $0.episodeId < $1.episodeId }
            try await local.upsertFilms(films)
            return .success(films)
        } catch {
            return .failure(error)
        }
    }

    func getFilmById(_ id: Int) async -> Result<Film, Error> {
        do {
            if let model = try await local.fetchFilm(byId: id) {
                return .success(model.toDomain())
            }

            let dto = try await api.fetchFilm(id: id)
            let film = dto.toDomain()
            try await local.upsertFilms([film])
            return .success(film)
        } catch {
            return .failure(error)
        }
    }

    func refreshFilm(id: Int) async -> Result<Film, Error> {
        do {
            let dto = try await api.fetchFilm(id: id)
            let film = dto.toDomain()
            try await local.upsertFilms([film])
            return .success(film)
        } catch {
            return .failure(error)
        }
    }
}

private extension FilmSwiftDataModel {
    func toDomain() -> Film {
        Film(
            id: id,
            title: title,
            episodeId: episodeId,
            openingCrawl: openingCrawl,
            director: director,
            producer: producer,
            releaseDate: releaseDate,
            charactersCount: charactersCount,
            planetsCount: planetsCount,
            starshipsCount: starshipsCount,
            vehiclesCount: vehiclesCount,
            speciesCount: speciesCount
        )
    }
}

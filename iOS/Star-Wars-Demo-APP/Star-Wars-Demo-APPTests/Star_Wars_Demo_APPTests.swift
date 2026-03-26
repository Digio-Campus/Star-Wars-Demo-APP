import Foundation
import SwiftData
import Testing
@testable import Star_Wars_Demo_APP

struct Star_Wars_Demo_APPTests {

    @Test func filmDTO_decodesAndMapsToDomain() async throws {
        let json = #"""
        {
          "title": "A New Hope",
          "episode_id": 4,
          "opening_crawl": "Hello there",
          "director": "George Lucas",
          "producer": "Gary Kurtz",
          "release_date": "1977-05-25",
          "characters": ["a", "b"],
          "planets": ["p"],
          "starships": [],
          "vehicles": ["v1", "v2", "v3"],
          "species": ["s"],
          "url": "https://swapi.info/api/films/1"
        }
        """#

        let dto = try JSONDecoder().decode(FilmDTO.self, from: Data(json.utf8))
        #expect(dto.episodeId == 4)

        let film = dto.toDomain()
        #expect(film.id == 1)
        #expect(film.title == "A New Hope")
        #expect(film.charactersCount == 2)
        #expect(film.vehiclesCount == 3)
    }

    @Test func listViewModel_searchResetsToPage1() async throws {
        let films = [
            Film(id: 1, title: "A New Hope", episodeId: 4, openingCrawl: "", director: "Lucas", producer: "", releaseDate: "", charactersCount: 0, planetsCount: 0, starshipsCount: 0, vehiclesCount: 0, speciesCount: 0),
            Film(id: 2, title: "The Empire Strikes Back", episodeId: 5, openingCrawl: "", director: "Kershner", producer: "", releaseDate: "", charactersCount: 0, planetsCount: 0, starshipsCount: 0, vehiclesCount: 0, speciesCount: 0),
            Film(id: 3, title: "Return of the Jedi", episodeId: 6, openingCrawl: "", director: "Marquand", producer: "", releaseDate: "", charactersCount: 0, planetsCount: 0, starshipsCount: 0, vehiclesCount: 0, speciesCount: 0),
            Film(id: 4, title: "The Phantom Menace", episodeId: 1, openingCrawl: "", director: "Lucas", producer: "", releaseDate: "", charactersCount: 0, planetsCount: 0, starshipsCount: 0, vehiclesCount: 0, speciesCount: 0)
        ]

        let repo = StubFilmRepository(films: films)
        let vm = await MainActor.run { FilmListViewModel(repository: repo) }

        await MainActor.run {
            vm.loadFilms()
        }
        try await Task.sleep(for: .milliseconds(50))

        await MainActor.run {
            vm.nextPage()
            #expect(vm.currentPage == 2)

            vm.searchQuery = "hope"
            #expect(vm.currentPage == 1)

            if case .success(let pageFilms, let current, let total) = vm.uiState {
                #expect(pageFilms.count == 1)
                #expect(current == 1)
                #expect(total == 1)
            } else {
                #expect(Bool(false))
            }
        }
    }

    @Test func repository_offlineFirstReadsCacheAndRefreshes() async throws {
        let schema = Schema([FilmSwiftDataModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])

        let local = FilmLocalDataSource(container: container)

        // Seed cache with a domain film.
        let cachedFilm = Film(
            id: 1,
            title: "Cached",
            episodeId: 4,
            openingCrawl: "",
            director: "",
            producer: "",
            releaseDate: "1977-05-25",
            charactersCount: 0,
            planetsCount: 0,
            starshipsCount: 0,
            vehiclesCount: 0,
            speciesCount: 0
        )
        try await local.upsertFilms([cachedFilm])

        let freshDTO = try JSONDecoder().decode(FilmDTO.self, from: Data(#"""
        {
          "title": "Fresh",
          "episode_id": 4,
          "opening_crawl": "",
          "director": "",
          "producer": "",
          "release_date": "1977-05-25",
          "characters": [],
          "planets": [],
          "starships": [],
          "vehicles": [],
          "species": [],
          "url": "https://swapi.info/api/films/1"
        }
        """#.utf8))

        let api = StubAPIService(films: [freshDTO])
        let repo = FilmRepositoryImpl(api: api, local: local)

        let cached = await repo.getFilms()
        guard case .success(let cachedFilms) = cached else {
            #expect(Bool(false))
            return
        }
        #expect(cachedFilms.first?.title == "Cached")

        let refreshed = await repo.refreshFilms()
        guard case .success(let refreshedFilms) = refreshed else {
            #expect(Bool(false))
            return
        }
        #expect(refreshedFilms.first?.title == "Fresh")

        let afterPersist = await repo.getFilms()
        guard case .success(let persisted) = afterPersist else {
            #expect(Bool(false))
            return
        }
        #expect(persisted.first?.title == "Fresh")
    }
}

// MARK: - Test Stubs

private struct StubFilmRepository: FilmRepository {
    let films: [Film]

    func getFilms() async -> Result<[Film], Error> { .success(films) }
    func refreshFilms() async -> Result<[Film], Error> { .success(films) }

    func getFilmById(_ id: Int) async -> Result<Film, Error> {
        if let film = films.first(where: { $0.id == id }) {
            return .success(film)
        }
        return .failure(NSError(domain: "test", code: 404))
    }

    func refreshFilm(id: Int) async -> Result<Film, Error> {
        await getFilmById(id)
    }
}

private final class StubAPIService: StarWarsAPIServiceProtocol {
    let films: [FilmDTO]
    init(films: [FilmDTO]) { self.films = films }

    func fetchFilms() async throws -> [FilmDTO] { films }

    func fetchFilm(id: Int) async throws -> FilmDTO {
        guard let dto = films.first(where: { $0.toDomain().id == id }) else {
            throw NSError(domain: "test", code: 404)
        }
        return dto
    }
}

import Foundation

enum StarWarsAPIError: Error {
    case invalidResponse
    case httpStatus(Int)
}

protocol StarWarsAPIServiceProtocol {
    func fetchFilms() async throws -> [FilmDTO]
    func fetchFilm(id: Int) async throws -> FilmDTO

    func fetchPeople() async throws -> [PersonDTO]
    func fetchPerson(id: Int) async throws -> PersonDTO

    func fetchPlanets() async throws -> [PlanetDTO]
    func fetchPlanet(id: Int) async throws -> PlanetDTO

    func fetchStarships() async throws -> [StarshipDTO]
    func fetchStarship(id: Int) async throws -> StarshipDTO
}

final class StarWarsAPIService: StarWarsAPIServiceProtocol {
    private let baseURL = URL(string: "https://swapi.dev/api/")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchFilms() async throws -> [FilmDTO] {
        // swapi.dev is paginated but films fit in the first page; we still use the generic pager.
        let url = baseURL.appending(path: "films")
        return try await fetchAllPages(url: url)
    }

    func fetchFilm(id: Int) async throws -> FilmDTO {
        let url = baseURL.appending(path: "films").appending(path: String(id))
        return try await request(url: url)
    }

    func fetchPeople() async throws -> [PersonDTO] {
        let url = baseURL.appending(path: "people")
        return try await fetchAllPages(url: url)
    }

    func fetchPerson(id: Int) async throws -> PersonDTO {
        let url = baseURL.appending(path: "people").appending(path: String(id))
        return try await request(url: url)
    }

    func fetchPlanets() async throws -> [PlanetDTO] {
        let url = baseURL.appending(path: "planets")
        return try await fetchAllPages(url: url)
    }

    func fetchPlanet(id: Int) async throws -> PlanetDTO {
        let url = baseURL.appending(path: "planets").appending(path: String(id))
        return try await request(url: url)
    }

    func fetchStarships() async throws -> [StarshipDTO] {
        let url = baseURL.appending(path: "starships")
        return try await fetchAllPages(url: url)
    }

    func fetchStarship(id: Int) async throws -> StarshipDTO {
        let url = baseURL.appending(path: "starships").appending(path: String(id))
        return try await request(url: url)
    }

    private struct PagedResponse<T: Decodable>: Decodable {
        let next: URL?
        let results: [T]

        enum CodingKeys: String, CodingKey { case next, results }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let nextStr = try container.decodeIfPresent(String.self, forKey: .next)
            self.next = nextStr.flatMap { URL(string: $0) }
            self.results = try container.decode([T].self, forKey: .results)
        }
    }

    private func fetchAllPages<T: Decodable>(url: URL) async throws -> [T] {
        var nextURL: URL? = url
        var all: [T] = []

        while let current = nextURL {
            let page: PagedResponse<T> = try await request(url: current)
            all.append(contentsOf: page.results)
            nextURL = page.next
        }

        return all
    }

    private func request<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw StarWarsAPIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw StarWarsAPIError.httpStatus(http.statusCode) }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

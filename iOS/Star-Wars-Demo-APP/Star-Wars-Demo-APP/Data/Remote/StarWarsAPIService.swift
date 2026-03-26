import Foundation

enum StarWarsAPIError: Error {
    case invalidResponse
    case httpStatus(Int)
}

protocol StarWarsAPIServiceProtocol {
    func fetchFilms() async throws -> [FilmDTO]
    func fetchFilm(id: Int) async throws -> FilmDTO
}

final class StarWarsAPIService: StarWarsAPIServiceProtocol {
    private let baseURL = URL(string: "https://swapi.info/api")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchFilms() async throws -> [FilmDTO] {
        let url = baseURL.appending(path: "films")
        return try await request(url: url)
    }

    func fetchFilm(id: Int) async throws -> FilmDTO {
        let url = baseURL.appending(path: "films").appending(path: String(id))
        return try await request(url: url)
    }

    private func request<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw StarWarsAPIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw StarWarsAPIError.httpStatus(http.statusCode) }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

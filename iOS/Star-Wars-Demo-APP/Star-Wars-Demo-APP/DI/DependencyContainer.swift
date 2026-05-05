import Foundation
import SwiftData

@MainActor
final class DependencyContainer {
    nonisolated static func makeDefaultSession() -> URLSession {
        let config = URLSessionConfiguration.default
        // Avoid indefinite-looking spinners on flaky networks.
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }

    let modelContainer: ModelContainer
    let apiService: StarWarsAPIServiceProtocol

    let filmLocalDataSource: FilmLocalDataSource
    let personLocalDataSource: PersonLocalDataSource
    let planetLocalDataSource: PlanetLocalDataSource
    let starshipLocalDataSource: StarshipLocalDataSource

    let filmRepository: FilmRepository
    let personRepository: PersonRepository
    let planetRepository: PlanetRepository
    let starshipRepository: StarshipRepository

    let vimeoService: VimeoServiceProtocol
    let vimeoRepository: VimeoRepository
    let videoResolver: VideoResolver

    init(
        modelContainer: ModelContainer,
        apiService: StarWarsAPIServiceProtocol = StarWarsAPIService(session: DependencyContainer.makeDefaultSession()),
        vimeoService: VimeoServiceProtocol = VimeoService(session: DependencyContainer.makeDefaultSession())
    ) {
        self.modelContainer = modelContainer
        self.apiService = apiService
        self.vimeoService = vimeoService

        self.filmLocalDataSource = FilmLocalDataSource(container: modelContainer)
        self.personLocalDataSource = PersonLocalDataSource(container: modelContainer)
        self.planetLocalDataSource = PlanetLocalDataSource(container: modelContainer)
        self.starshipLocalDataSource = StarshipLocalDataSource(container: modelContainer)

        self.filmRepository = FilmRepositoryImpl(api: apiService, local: filmLocalDataSource)
        self.personRepository = PersonRepositoryImpl(api: apiService, local: personLocalDataSource)
        self.planetRepository = PlanetRepositoryImpl(api: apiService, local: planetLocalDataSource)
        self.starshipRepository = StarshipRepositoryImpl(api: apiService, local: starshipLocalDataSource)

        self.vimeoRepository = VimeoRepositoryImpl(service: vimeoService)
        self.videoResolver = VideoResolverImpl(
            vimeoRepository: self.vimeoRepository,
            youTubeProvider: YouTubeProvider(session: DependencyContainer.makeDefaultSession())
        )
    }
}

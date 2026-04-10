import Foundation
import SwiftData

@MainActor
final class DependencyContainer {
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

    init(modelContainer: ModelContainer, apiService: StarWarsAPIServiceProtocol = StarWarsAPIService()) {
        self.modelContainer = modelContainer
        self.apiService = apiService

        self.filmLocalDataSource = FilmLocalDataSource(container: modelContainer)
        self.personLocalDataSource = PersonLocalDataSource(container: modelContainer)
        self.planetLocalDataSource = PlanetLocalDataSource(container: modelContainer)
        self.starshipLocalDataSource = StarshipLocalDataSource(container: modelContainer)

        self.filmRepository = FilmRepositoryImpl(api: apiService, local: filmLocalDataSource)
        self.personRepository = PersonRepositoryImpl(api: apiService, local: personLocalDataSource)
        self.planetRepository = PlanetRepositoryImpl(api: apiService, local: planetLocalDataSource)
        self.starshipRepository = StarshipRepositoryImpl(api: apiService, local: starshipLocalDataSource)
    }
}

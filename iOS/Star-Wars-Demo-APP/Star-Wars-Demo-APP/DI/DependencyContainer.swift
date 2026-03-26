import Foundation
import SwiftData

@MainActor
final class DependencyContainer {
    let modelContainer: ModelContainer
    let apiService: StarWarsAPIServiceProtocol
    let localDataSource: FilmLocalDataSource
    let filmRepository: FilmRepository

    init(modelContainer: ModelContainer, apiService: StarWarsAPIServiceProtocol = StarWarsAPIService()) {
        self.modelContainer = modelContainer
        self.apiService = apiService
        self.localDataSource = FilmLocalDataSource(container: modelContainer)
        self.filmRepository = FilmRepositoryImpl(api: apiService, local: localDataSource)
    }
}

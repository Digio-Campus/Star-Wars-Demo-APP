import Foundation

@MainActor
final class PlanetDetailViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case success(Planet)
        case error(message: String)
    }

    @Published private(set) var uiState: UiState = .loading

    private let planetId: Int
    private let repository: PlanetRepository
    private var task: Task<Void, Never>?

    init(planetId: Int, repository: PlanetRepository) {
        self.planetId = planetId
        self.repository = repository
    }

    func load() {
        task?.cancel()
        uiState = .loading

        task = Task { @MainActor in
            let cached = await repository.getPlanetById(planetId)
            if case .success(let planet) = cached {
                uiState = .success(planet)
            }

            let fresh = await repository.refreshPlanet(id: planetId)
            switch fresh {
            case .success(let planet):
                uiState = .success(planet)
            case .failure(let error):
                if case .loading = uiState {
                    uiState = .error(message: error.localizedDescription)
                }
            }
        }
    }
}

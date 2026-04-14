import Foundation

@MainActor
final class StarshipDetailViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case success(Starship)
        case error(message: String)
    }

    @Published private(set) var uiState: UiState = .loading

    private let starshipId: Int
    private let repository: StarshipRepository
    private var task: Task<Void, Never>?

    init(starshipId: Int, repository: StarshipRepository) {
        self.starshipId = starshipId
        self.repository = repository
    }

    func load() {
        task?.cancel()
        uiState = .loading

        task = Task { @MainActor in
            let cached = await repository.getStarshipById(starshipId)
            if case .success(let starship) = cached {
                uiState = .success(starship)
            }

            let fresh = await repository.refreshStarship(id: starshipId)
            switch fresh {
            case .success(let starship):
                uiState = .success(starship)
            case .failure(let error):
                if case .loading = uiState {
                    uiState = .error(message: error.localizedDescription)
                }
            }
        }
    }
}

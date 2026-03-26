import Foundation

@MainActor
final class FilmDetailViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case success(Film)
        case error(message: String)
    }

    @Published private(set) var uiState: UiState = .loading

    private let filmId: Int
    private let repository: FilmRepository
    private var task: Task<Void, Never>?

    init(filmId: Int, repository: FilmRepository) {
        self.filmId = filmId
        self.repository = repository
    }

    func load() {
        task?.cancel()
        uiState = .loading

        task = Task {
            let cached = await repository.getFilmById(filmId)
            if case .success(let film) = cached {
                uiState = .success(film)
            }

            let fresh = await repository.refreshFilm(id: filmId)
            switch fresh {
            case .success(let film):
                uiState = .success(film)
            case .failure(let error):
                if case .loading = uiState {
                    uiState = .error(message: error.localizedDescription)
                }
            }
        }
    }
}

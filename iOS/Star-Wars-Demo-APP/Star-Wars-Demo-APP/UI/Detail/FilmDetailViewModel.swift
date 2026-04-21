import Foundation

@MainActor
final class FilmDetailViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case success(Film)
        case error(message: String)
    }

    @Published private(set) var uiState: UiState = .loading

    @Published private(set) var vimeoVideo: VimeoVideo?
    @Published private(set) var isLoadingVimeoVideo: Bool = false
    @Published private(set) var vimeoErrorMessage: String?

    private let filmId: Int
    private let repository: FilmRepository
    private let vimeoRepository: VimeoRepository

    private var task: Task<Void, Never>?
    private var lastVimeoTitleKey: String?

    init(filmId: Int, repository: FilmRepository, vimeoRepository: VimeoRepository) {
        self.filmId = filmId
        self.repository = repository
        self.vimeoRepository = vimeoRepository
    }

    func load() {
        task?.cancel()

        uiState = .loading
        vimeoVideo = nil
        vimeoErrorMessage = nil
        isLoadingVimeoVideo = false
        lastVimeoTitleKey = nil

        task = Task {
            let cached = await repository.getFilmById(filmId)
            if case .success(let film) = cached {
                uiState = .success(film)
                await loadVimeoVideo()
            }

            let fresh = await repository.refreshFilm(id: filmId)
            switch fresh {
            case .success(let film):
                uiState = .success(film)
                await loadVimeoVideo()
            case .failure(let error):
                if case .loading = uiState {
                    uiState = .error(message: error.localizedDescription)
                }
            }
        }
    }

    func loadVimeoVideo() async {
        guard case .success(let film) = uiState else { return }

        if isLoadingVimeoVideo { return }

        let titleKey = film.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if lastVimeoTitleKey == titleKey, vimeoErrorMessage == nil { return }
        lastVimeoTitleKey = titleKey

        isLoadingVimeoVideo = true
        vimeoErrorMessage = nil
        defer { isLoadingVimeoVideo = false }

        do {
            vimeoVideo = try await vimeoRepository.searchVimeoVideo(title: film.title)
        } catch is CancellationError {
            return
        } catch {
            vimeoVideo = nil
            vimeoErrorMessage = error.localizedDescription
        }
    }
}

import Foundation

@MainActor
final class FilmDetailViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case success(Film)
        case error(message: String)
    }

    @Published private(set) var uiState: UiState = .loading

    // Video playback state
    @Published private(set) var playbackTarget: PlaybackTarget?
    @Published private(set) var isLoadingVideo: Bool = false
    @Published private(set) var videoErrorMessage: String?

    private let filmId: Int
    private let repository: FilmRepository
    private let videoResolver: VideoResolver?
    private var task: Task<Void, Never>?

    init(filmId: Int, repository: FilmRepository, videoResolver: VideoResolver? = nil) {
        self.filmId = filmId
        self.repository = repository
        self.videoResolver = videoResolver
    }

    func load() {
        task?.cancel()
        uiState = .loading
        playbackTarget = nil
        videoErrorMessage = nil

        task = Task {
            let cached = await repository.getFilmById(filmId)
            if case .success(let film) = cached {
                uiState = .success(film)
                await loadVideo()
            }

            let fresh = await repository.refreshFilm(id: filmId)
            switch fresh {
            case .success(let film):
                uiState = .success(film)
                await loadVideo()
            case .failure(let error):
                if case .loading = uiState {
                    uiState = .error(message: error.localizedDescription)
                }
            }
        }
    }

    func loadVideo() async {
        guard case .success(let film) = uiState else { return }
        if isLoadingVideo { return }

        isLoadingVideo = true
        videoErrorMessage = nil
        defer { isLoadingVideo = false }

        guard let resolver = videoResolver else { return }

        do {
            if let (candidate, target) = try await resolver.resolveVideo(title: film.title) {
                playbackTarget = target
                return
            }
        } catch {
            videoErrorMessage = error.localizedDescription
        }
    }
}

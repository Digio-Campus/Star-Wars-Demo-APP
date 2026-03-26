import Foundation

@MainActor
final class FilmListViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case empty
        case success(films: [Film], currentPage: Int, totalPages: Int)
        case error(message: String)
    }

    @Published private(set) var uiState: UiState = .loading
    @Published var searchQuery: String = "" {
        didSet {
            currentPage = 1
            publish()
        }
    }
    @Published private(set) var currentPage: Int = 1

    let itemsPerPage = 3

    private let repository: FilmRepository
    private var allFilms: [Film] = []
    private var refreshTask: Task<Void, Never>?

    init(repository: FilmRepository) {
        self.repository = repository
    }

    func loadFilms() {
        refreshTask?.cancel()
        uiState = .loading

        refreshTask = Task {
            let cached = await repository.getFilms()
            switch cached {
            case .success(let films):
                self.allFilms = films
                self.publish(showLoadingWhenEmpty: true)
            case .failure:
                self.allFilms = []
            }

            let fresh = await repository.refreshFilms()
            switch fresh {
            case .success(let films):
                self.allFilms = films
                self.publish(showLoadingWhenEmpty: false)
            case .failure(let error):
                if self.allFilms.isEmpty {
                    self.uiState = .error(message: error.localizedDescription)
                }
            }
        }
    }

    func nextPage() {
        let total = totalPages(for: filteredFilms)
        guard currentPage < total else { return }
        currentPage += 1
        publish()
    }

    func previousPage() {
        guard currentPage > 1 else { return }
        currentPage -= 1
        publish()
    }

    // MARK: - Private

    private var filteredFilms: [Film] {
        let base = allFilms.sorted { $0.episodeId < $1.episodeId }
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return base }
        return base.filter { $0.title.localizedCaseInsensitiveContains(q) }
    }

    private func totalPages(for films: [Film]) -> Int {
        guard !films.isEmpty else { return 1 }
        return Int(ceil(Double(films.count) / Double(itemsPerPage)))
    }

    private func pageSlice(for films: [Film]) -> [Film] {
        guard !films.isEmpty else { return [] }
        let total = totalPages(for: films)
        let clamped = min(max(currentPage, 1), total)
        if clamped != currentPage {
            currentPage = clamped
        }
        let start = (clamped - 1) * itemsPerPage
        let end = min(start + itemsPerPage, films.count)
        guard start < end else { return [] }
        return Array(films[start..<end])
    }

    private func publish(showLoadingWhenEmpty: Bool = false) {
        let films = filteredFilms
        if films.isEmpty {
            uiState = showLoadingWhenEmpty && allFilms.isEmpty ? .loading : .empty
            return
        }

        let total = totalPages(for: films)
        let pageFilms = pageSlice(for: films)
        uiState = .success(films: pageFilms, currentPage: currentPage, totalPages: total)
    }
}

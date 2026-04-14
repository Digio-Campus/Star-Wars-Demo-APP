import Foundation

@MainActor
final class FilmListViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case empty
        case success(films: [Film])
        case error(message: String)
    }

    @Published private(set) var uiState: UiState = .loading
    @Published var searchQuery: String = "" {
        didSet {
            resetPaging()
            publish()
        }
    }
    @Published private(set) var currentPage: Int = 1
    @Published private(set) var isLoadingMore: Bool = false

    let itemsPerPage = 3

    private let repository: FilmRepository
    private var allFilms: [Film] = []
    private var refreshTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    private var lastLoadMorePageRequested: Int = 0

    init(repository: FilmRepository) {
        self.repository = repository
    }

    var canLoadMore: Bool {
        currentPage < totalPages(for: filteredFilms)
    }

    func loadFilms() {
        refreshTask?.cancel()
        loadMoreTask?.cancel()
        resetPaging()
        uiState = .loading

        refreshTask = Task { @MainActor in
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

    func loadNextPageIfNeeded() {
        let total = totalPages(for: filteredFilms)
        guard currentPage < total else { return }
        guard !isLoadingMore else { return }
        guard lastLoadMorePageRequested != currentPage else { return }

        lastLoadMorePageRequested = currentPage
        isLoadingMore = true

        loadMoreTask?.cancel()
        loadMoreTask = Task { @MainActor in
            await Task.yield()
            currentPage += 1
            publish()
            isLoadingMore = false
        }
    }

    // MARK: - Private

    private func resetPaging() {
        currentPage = 1
        lastLoadMorePageRequested = 0
        isLoadingMore = false
        loadMoreTask?.cancel()
        loadMoreTask = nil
    }

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

        let pageFilms = pageSlice(for: films)
        uiState = .success(films: pageFilms)
    }
}

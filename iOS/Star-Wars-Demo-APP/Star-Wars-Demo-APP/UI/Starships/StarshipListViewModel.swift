import Foundation

@MainActor
final class StarshipListViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case empty
        case success(starships: [Starship])
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

    let itemsPerPage = 10

    private let repository: StarshipRepository
    private var allStarships: [Starship] = []
    private var refreshTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    private var lastLoadMorePageRequested: Int = 0

    init(repository: StarshipRepository) {
        self.repository = repository
    }

    var canLoadMore: Bool {
        currentPage < totalPages(for: filteredStarships)
    }

    func loadStarships() {
        refreshTask?.cancel()
        loadMoreTask?.cancel()
        resetPaging()
        uiState = .loading

        refreshTask = Task { @MainActor in
            let cached = await repository.getStarships()
            switch cached {
            case .success(let starships):
                self.allStarships = starships
                self.publish(showLoadingWhenEmpty: true)
            case .failure:
                self.allStarships = []
            }

            let fresh = await repository.refreshStarships()
            switch fresh {
            case .success(let starships):
                self.allStarships = starships
                self.publish(showLoadingWhenEmpty: false)
            case .failure(let error):
                if self.allStarships.isEmpty {
                    self.uiState = .error(message: error.localizedDescription)
                }
            }
        }
    }

    func loadNextPageIfNeeded() {
        let total = totalPages(for: filteredStarships)
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

    private var filteredStarships: [Starship] {
        let base = allStarships.sorted { $0.name < $1.name }
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    private func totalPages(for starships: [Starship]) -> Int {
        guard !starships.isEmpty else { return 1 }
        return Int(ceil(Double(starships.count) / Double(itemsPerPage)))
    }

    private func pageSlice(for starships: [Starship]) -> [Starship] {
        guard !starships.isEmpty else { return [] }
        let total = totalPages(for: starships)
        let clamped = min(max(currentPage, 1), total)
        if clamped != currentPage {
            currentPage = clamped
        }
        let start = (clamped - 1) * itemsPerPage
        let end = min(start + itemsPerPage, starships.count)
        guard start < end else { return [] }
        return Array(starships[start..<end])
    }

    private func publish(showLoadingWhenEmpty: Bool = false) {
        let starships = filteredStarships
        if starships.isEmpty {
            uiState = showLoadingWhenEmpty && allStarships.isEmpty ? .loading : .empty
            return
        }

        let pageStarships = pageSlice(for: starships)
        uiState = .success(starships: pageStarships)
    }
}

import Foundation

@MainActor
final class PlanetListViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case empty
        case success(planets: [Planet])
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

    private let repository: PlanetRepository
    private var allPlanets: [Planet] = []
    private var refreshTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    private var lastLoadMorePageRequested: Int = 0

    init(repository: PlanetRepository) {
        self.repository = repository
    }

    var canLoadMore: Bool {
        currentPage < totalPages(for: filteredPlanets)
    }

    func loadPlanets() {
        refreshTask?.cancel()
        loadMoreTask?.cancel()
        resetPaging()
        uiState = .loading

        refreshTask = Task { @MainActor in
            let cached = await repository.getPlanets()
            switch cached {
            case .success(let planets):
                self.allPlanets = planets
                self.publish(showLoadingWhenEmpty: true)
            case .failure:
                self.allPlanets = []
            }

            let fresh = await repository.refreshPlanets()
            switch fresh {
            case .success(let planets):
                self.allPlanets = planets
                self.publish(showLoadingWhenEmpty: false)
            case .failure(let error):
                if self.allPlanets.isEmpty {
                    self.uiState = .error(message: error.localizedDescription)
                }
            }
        }
    }

    func loadNextPageIfNeeded() {
        let total = totalPages(for: filteredPlanets)
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

    private var filteredPlanets: [Planet] {
        let base = allPlanets.sorted { $0.name < $1.name }
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    private func totalPages(for planets: [Planet]) -> Int {
        guard !planets.isEmpty else { return 1 }
        return Int(ceil(Double(planets.count) / Double(itemsPerPage)))
    }

    private func pageSlice(for planets: [Planet]) -> [Planet] {
        guard !planets.isEmpty else { return [] }
        let total = totalPages(for: planets)
        let clamped = min(max(currentPage, 1), total)
        if clamped != currentPage {
            currentPage = clamped
        }
        let start = (clamped - 1) * itemsPerPage
        let end = min(start + itemsPerPage, planets.count)
        guard start < end else { return [] }
        return Array(planets[start..<end])
    }

    private func publish(showLoadingWhenEmpty: Bool = false) {
        let planets = filteredPlanets
        if planets.isEmpty {
            uiState = showLoadingWhenEmpty && allPlanets.isEmpty ? .loading : .empty
            return
        }

        let pagePlanets = pageSlice(for: planets)
        uiState = .success(planets: pagePlanets)
    }
}

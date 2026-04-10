import Foundation

@MainActor
final class PlanetListViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case empty
        case success(planets: [Planet], currentPage: Int, totalPages: Int)
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

    let itemsPerPage = 10

    private let repository: PlanetRepository
    private var allPlanets: [Planet] = []
    private var refreshTask: Task<Void, Never>?

    init(repository: PlanetRepository) {
        self.repository = repository
    }

    func loadPlanets() {
        refreshTask?.cancel()
        uiState = .loading

        refreshTask = Task {
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

    func nextPage() {
        let total = totalPages(for: filteredPlanets)
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

        let total = totalPages(for: planets)
        let pagePlanets = pageSlice(for: planets)
        uiState = .success(planets: pagePlanets, currentPage: currentPage, totalPages: total)
    }
}

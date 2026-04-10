import Foundation

@MainActor
final class StarshipListViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case empty
        case success(starships: [Starship], currentPage: Int, totalPages: Int)
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

    private let repository: StarshipRepository
    private var allStarships: [Starship] = []
    private var refreshTask: Task<Void, Never>?

    init(repository: StarshipRepository) {
        self.repository = repository
    }

    func loadStarships() {
        refreshTask?.cancel()
        uiState = .loading

        refreshTask = Task {
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

    func nextPage() {
        let total = totalPages(for: filteredStarships)
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

        let total = totalPages(for: starships)
        let pageStarships = pageSlice(for: starships)
        uiState = .success(starships: pageStarships, currentPage: currentPage, totalPages: total)
    }
}

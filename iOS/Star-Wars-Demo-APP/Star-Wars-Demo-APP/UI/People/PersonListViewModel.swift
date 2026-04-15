import Foundation

@MainActor
final class PersonListViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case empty
        case success(people: [Person])
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

    private let repository: PersonRepository
    private var allPeople: [Person] = []
    private var refreshTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    private var lastLoadMorePageRequested: Int = 0

    init(repository: PersonRepository) {
        self.repository = repository
    }

    var canLoadMore: Bool {
        currentPage < totalPages(for: filteredPeople)
    }

    func loadPeople() {
        refreshTask?.cancel()
        loadMoreTask?.cancel()
        resetPaging()
        uiState = .loading

        refreshTask = Task { @MainActor in
            let cached = await repository.getPeople()
            switch cached {
            case .success(let people):
                self.allPeople = people
                self.publish(showLoadingWhenEmpty: true)
            case .failure:
                self.allPeople = []
            }

            let fresh = await repository.refreshPeople()
            switch fresh {
            case .success(let people):
                self.allPeople = people
                self.publish(showLoadingWhenEmpty: false)
            case .failure(let error):
                if self.allPeople.isEmpty {
                    self.uiState = .error(message: error.localizedDescription)
                }
            }
        }
    }

    func loadNextPageIfNeeded() {
        let total = totalPages(for: filteredPeople)
        guard currentPage < total else { return }

        let nextPage = currentPage + 1
        guard !isLoadingMore else { return }
        guard lastLoadMorePageRequested != nextPage else { return }

        lastLoadMorePageRequested = nextPage
        isLoadingMore = true

        loadMoreTask?.cancel()
        loadMoreTask = Task { @MainActor in
            currentPage = nextPage
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

    private var filteredPeople: [Person] {
        let base = allPeople.sorted { $0.name < $1.name }
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    private func totalPages(for people: [Person]) -> Int {
        guard !people.isEmpty else { return 1 }
        return Int(ceil(Double(people.count) / Double(itemsPerPage)))
    }

    private func pageSlice(for people: [Person]) -> [Person] {
        guard !people.isEmpty else { return [] }

        let total = totalPages(for: people)
        let clamped = min(max(currentPage, 1), total)
        if clamped != currentPage {
            currentPage = clamped
        }

        let end = min(clamped * itemsPerPage, people.count)
        return Array(people.prefix(end))
    }

    private func publish(showLoadingWhenEmpty: Bool = false) {
        let people = filteredPeople
        if people.isEmpty {
            uiState = showLoadingWhenEmpty && allPeople.isEmpty ? .loading : .empty
            return
        }

        let pagePeople = pageSlice(for: people)
        uiState = .success(people: pagePeople)
    }
}

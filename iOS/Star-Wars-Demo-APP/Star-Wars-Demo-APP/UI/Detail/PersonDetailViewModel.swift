import Foundation

@MainActor
final class PersonDetailViewModel: ObservableObject {
    enum UiState: Equatable {
        case loading
        case success(Person)
        case error(message: String)
    }

    @Published private(set) var uiState: UiState = .loading

    private let personId: Int
    private let repository: PersonRepository
    private var task: Task<Void, Never>?

    init(personId: Int, repository: PersonRepository) {
        self.personId = personId
        self.repository = repository
    }

    func load() {
        task?.cancel()
        uiState = .loading

        task = Task { @MainActor in
            let cached = await repository.getPersonById(personId)
            if case .success(let person) = cached {
                uiState = .success(person)
            }

            let fresh = await repository.refreshPerson(id: personId)
            switch fresh {
            case .success(let person):
                uiState = .success(person)
            case .failure(let error):
                if case .loading = uiState {
                    uiState = .error(message: error.localizedDescription)
                }
            }
        }
    }
}

import SwiftUI

struct PersonListView: View {
    private let repository: PersonRepository
    @StateObject private var viewModel: PersonListViewModel
    private let title = "Star Wars People"

    init(repository: PersonRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: PersonListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .background(StarWarsColors.background)
                .task {
                    await viewModel.loadPeople()
                }
                .navigationDestination(for: Int.self) { personId in
                    PersonDetailView(repository: repository, personId: personId)
                }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 12) {
                SearchBarView(text: $viewModel.searchQuery, placeholder: "Search by name")

                switch viewModel.uiState {
                case .loading:
                    LoadingView()
                        .frame(maxWidth: .infinity, minHeight: 300)

                case .empty:
                    ContentUnavailableView(
                        "No people",
                        systemImage: "person.2",
                        description: Text("Try a different search.")
                    )
                    .frame(maxWidth: .infinity, minHeight: 300)

                case .error(let message):
                    ErrorView(message: message) {
                        Task { await viewModel.loadPeople() }
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)

                case .success(let people):
                    LazyVStack(spacing: 12) {
                        ForEach(people) { person in
                            NavigationLink(value: person.id) {
                                PersonCardView(person: person)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deletePerson(person)
                                } label: {
                                    Text("DELETE")
                                }
                                .tint(.red)
                            }
                        }

                        InfiniteScrollFooterView(
                            isLoading: viewModel.isLoadingMore,
                            canLoadMore: viewModel.canLoadMore,
                            onLoadMore: viewModel.loadNextPageIfNeeded
                        )
                    }
                }
            }
            .padding(.top, 4)
        }
        .refreshable {
            await viewModel.loadPeople()
        }
    }

    private func deletePerson(_ person: Person) {
        Task { await viewModel.deleteItem(id: person.id) }
    }
}

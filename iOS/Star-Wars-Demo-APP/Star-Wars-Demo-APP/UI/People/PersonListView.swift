import SwiftUI

struct PersonListView: View {
    private let repository: PersonRepository
    @StateObject private var viewModel: PersonListViewModel

    init(repository: PersonRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: PersonListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                SearchBarView(text: $viewModel.searchQuery, placeholder: "Search by name")
                content
            }
            .navigationTitle("Star Wars People")
            .navigationBarTitleDisplayMode(.large)
            .background(StarWarsColors.background)
            .task {
                viewModel.loadPeople()
            }
            .navigationDestination(for: Int.self) { personId in
                PersonDetailView(repository: repository, personId: personId)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.uiState {
        case .loading:
            LoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty:
            ContentUnavailableView(
                "No people",
                systemImage: "person.2",
                description: Text("Try a different search.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .error(let message):
            ErrorView(message: message) {
                viewModel.loadPeople()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .success(let people):
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(people) { person in
                        NavigationLink(value: person.id) {
                            PersonCardView(person: person)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }

                    InfiniteScrollFooterView(
                        isLoading: viewModel.isLoadingMore,
                        canLoadMore: viewModel.canLoadMore,
                        onLoadMore: viewModel.loadNextPageIfNeeded
                    )
                    .id(viewModel.currentPage)
                }
                .padding(.top, 4)
            }
        }
    }
}

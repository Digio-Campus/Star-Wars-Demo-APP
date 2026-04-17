import SwiftUI

struct StarshipListView: View {
    private let repository: StarshipRepository
    @StateObject private var viewModel: StarshipListViewModel
    private let title = "Star Wars Starships"

    init(repository: StarshipRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: StarshipListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .background(StarWarsColors.background)
                .task {
                    await viewModel.loadStarships()
                }
                .navigationDestination(for: Int.self) { starshipId in
                    StarshipDetailView(repository: repository, starshipId: starshipId)
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
                        "No starships",
                        systemImage: "airplane",
                        description: Text("Try a different search.")
                    )
                    .frame(maxWidth: .infinity, minHeight: 300)

                case .error(let message):
                    ErrorView(message: message) {
                        Task { await viewModel.loadStarships() }
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)

                case .success(let starships):
                    LazyVStack(spacing: 12) {
                        ForEach(starships) { starship in
                            NavigationLink(value: starship.id) {
                                StarshipCardView(starship: starship)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteStarship(starship)
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
            await viewModel.loadStarships()
        }
    }

    private func deleteStarship(_ starship: Starship) {
        Task { await viewModel.deleteItem(id: starship.id) }
    }
}

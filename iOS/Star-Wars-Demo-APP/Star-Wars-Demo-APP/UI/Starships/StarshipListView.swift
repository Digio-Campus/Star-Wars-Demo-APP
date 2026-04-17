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
        List {
            SearchBarView(text: $viewModel.searchQuery, placeholder: "Search by name")
                .padding(.vertical, 4)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            switch viewModel.uiState {
            case .loading:
                LoadingView()
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

            case .empty:
                ContentUnavailableView(
                    "No starships",
                    systemImage: "airplane",
                    description: Text("Try a different search.")
                )
                .frame(maxWidth: .infinity, minHeight: 300)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            case .error(let message):
                ErrorView(message: message) {
                    Task { await viewModel.loadStarships() }
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            case .success(let starships):
                ForEach(starships) { starship in
                    NavigationLink(value: starship.id) {
                        StarshipCardView(starship: starship)
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
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
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            await viewModel.loadStarships()
        }
    }

    private func deleteStarship(_ starship: Starship) {
        Task { await viewModel.deleteItem(id: starship.id) }
    }
}

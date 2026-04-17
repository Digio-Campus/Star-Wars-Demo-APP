import SwiftUI

struct PlanetListView: View {
    private let repository: PlanetRepository
    @StateObject private var viewModel: PlanetListViewModel
    private let title = "Star Wars Planets"

    init(repository: PlanetRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: PlanetListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .background(StarWarsColors.background)
                .task {
                    await viewModel.loadPlanets()
                }
                .navigationDestination(for: Int.self) { planetId in
                    PlanetDetailView(repository: repository, planetId: planetId)
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
                    "No planets",
                    systemImage: "globe",
                    description: Text("Try a different search.")
                )
                .frame(maxWidth: .infinity, minHeight: 300)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            case .error(let message):
                ErrorView(message: message) {
                    Task { await viewModel.loadPlanets() }
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            case .success(let planets):
                ForEach(planets) { planet in
                    NavigationLink(value: planet.id) {
                        PlanetCardView(planet: planet)
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deletePlanet(planet)
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
            await viewModel.loadPlanets()
        }
    }

    private func deletePlanet(_ planet: Planet) {
        Task { await viewModel.deleteItem(id: planet.id) }
    }
}

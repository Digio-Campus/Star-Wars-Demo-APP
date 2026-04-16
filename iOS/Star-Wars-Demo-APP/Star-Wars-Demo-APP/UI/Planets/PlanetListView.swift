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
            VStack(spacing: 12) {
                SearchBarView(text: $viewModel.searchQuery, placeholder: "Search by name")
                content
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .background(StarWarsColors.background)
            .task {
                viewModel.loadPlanets()
            }
            .navigationDestination(for: Int.self) { planetId in
                PlanetDetailView(repository: repository, planetId: planetId)
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
                "No planets",
                systemImage: "globe",
                description: Text("Try a different search.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .error(let message):
            ErrorView(message: message) {
                viewModel.loadPlanets()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .success(let planets):
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(planets) { planet in
                        NavigationLink(value: planet.id) {
                            PlanetCardView(planet: planet)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }

                    InfiniteScrollFooterView(
                        isLoading: viewModel.isLoadingMore,
                        canLoadMore: viewModel.canLoadMore,
                        onLoadMore: viewModel.loadNextPageIfNeeded
                    )
                }
                .padding(.top, 4)
            }
        }
    }
}

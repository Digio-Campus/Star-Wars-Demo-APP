import SwiftUI

struct PlanetListView: View {
    private let repository: PlanetRepository
    @StateObject private var viewModel: PlanetListViewModel

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
            .navigationTitle("Star Wars Planets")
            .background(StarWarsColors.background)
            .task {
                viewModel.loadPlanets()
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

        case .success(let planets, let page, let totalPages):
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(planets) { planet in
                        PlanetCardView(planet: planet)
                            .padding(.horizontal)
                    }

                    PaginationView(
                        current: page,
                        total: totalPages,
                        onPrevious: viewModel.previousPage,
                        onNext: viewModel.nextPage
                    )
                }
                .padding(.top, 4)
            }
        }
    }
}

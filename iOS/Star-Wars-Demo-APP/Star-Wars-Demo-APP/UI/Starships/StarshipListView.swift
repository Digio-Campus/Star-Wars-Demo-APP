import SwiftUI

struct StarshipListView: View {
    private let repository: StarshipRepository
    @StateObject private var viewModel: StarshipListViewModel

    init(repository: StarshipRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: StarshipListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                SearchBarView(text: $viewModel.searchQuery, placeholder: "Search by name")
                content
            }
            .navigationTitle("Star Wars Starships")
            .background(StarWarsColors.background)
            .task {
                viewModel.loadStarships()
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
                "No starships",
                systemImage: "airplane",
                description: Text("Try a different search.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .error(let message):
            ErrorView(message: message) {
                viewModel.loadStarships()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .success(let starships, let page, let totalPages):
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(starships) { starship in
                        StarshipCardView(starship: starship)
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

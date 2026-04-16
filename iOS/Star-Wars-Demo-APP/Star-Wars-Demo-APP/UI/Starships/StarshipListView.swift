import SwiftUI

struct StarshipListView: View {
    private let repository: StarshipRepository
    @StateObject private var viewModel: StarshipListViewModel
    @State private var scrollOffset: CGFloat = 0

    private let scrollSpaceName = "starship-list-scroll"
    private let title = "Star Wars Starships"

    init(repository: StarshipRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: StarshipListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                CollapsibleLargeTitleHeader(title: title, scrollOffset: scrollOffset)
                    .padding(.horizontal)
                    .padding(.top, 4)

                SearchBarView(text: $viewModel.searchQuery, placeholder: "Search by name")
                content
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(StarWarsColors.background)
            .task {
                viewModel.loadStarships()
            }
            .navigationDestination(for: Int.self) { starshipId in
                StarshipDetailView(repository: repository, starshipId: starshipId)
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

        case .success(let starships):
            ScrollView {
                ScrollOffsetReader(coordinateSpaceName: scrollSpaceName)

                LazyVStack(spacing: 12) {
                    ForEach(starships) { starship in
                        NavigationLink(value: starship.id) {
                            StarshipCardView(starship: starship)
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
            .coordinateSpace(.named(scrollSpaceName))
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                updateScrollOffset(with: offset)
            }
        }
    }

    private func updateScrollOffset(with offset: CGFloat) {
        let clamped = min(offset, 0)
        guard abs(clamped - scrollOffset) > 0.25 else { return }
        scrollOffset = clamped
    }
}

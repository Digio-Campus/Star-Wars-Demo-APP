import SwiftUI

struct FilmListView: View {
    private let repository: FilmRepository

    @StateObject private var viewModel: FilmListViewModel
    @State private var scrollOffset: CGFloat = 0

    private let scrollSpaceName = "film-list-scroll"
    private let title = "Star Wars Films"

    init(repository: FilmRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: FilmListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                CollapsibleLargeTitleHeader(title: title, scrollOffset: scrollOffset)
                    .padding(.horizontal)
                    .padding(.top, 4)

                SearchBarView(text: $viewModel.searchQuery, placeholder: "Search by title")
                content
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(StarWarsColors.background)
            .task {
                viewModel.loadFilms()
            }
            .navigationDestination(for: Int.self) { filmId in
                FilmDetailView(repository: repository, filmId: filmId)
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
                "No films",
                systemImage: "film",
                description: Text("Try a different search.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .error(let message):
            ErrorView(message: message) {
                viewModel.loadFilms()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .success(let films):
            ScrollView {
                ScrollOffsetReader(coordinateSpaceName: scrollSpaceName)

                LazyVStack(spacing: 12) {
                    ForEach(films) { film in
                        NavigationLink(value: film.id) {
                            FilmCardView(film: film)
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

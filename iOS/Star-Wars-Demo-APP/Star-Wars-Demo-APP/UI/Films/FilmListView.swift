import SwiftUI

struct FilmListView: View {
    private let repository: FilmRepository

    @StateObject private var viewModel: FilmListViewModel
    @State private var isTitleCollapsed = false

    private let scrollSpaceName = "film-list-scroll"

    init(repository: FilmRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: FilmListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                SearchBarView(text: $viewModel.searchQuery, placeholder: "Search by title")
                content
            }
            .navigationTitle("Star Wars Films")
            .navigationBarTitleDisplayMode(isTitleCollapsed ? .inline : .large)
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
            .coordinateSpace(name: scrollSpaceName)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                updateTitleCollapse(with: offset)
            }
        }
    }

    private func updateTitleCollapse(with offset: CGFloat) {
        // Hysteresis avoids flip-flopping if the user hovers near the threshold.
        let collapseAt: CGFloat = -32
        let expandAt: CGFloat = -8

        if !isTitleCollapsed, offset < collapseAt {
            withAnimation(.easeInOut(duration: 0.2)) {
                isTitleCollapsed = true
            }
        } else if isTitleCollapsed, offset > expandAt {
            withAnimation(.easeInOut(duration: 0.2)) {
                isTitleCollapsed = false
            }
        }
    }
}

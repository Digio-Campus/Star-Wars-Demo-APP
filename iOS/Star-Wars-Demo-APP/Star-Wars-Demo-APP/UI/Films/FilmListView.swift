import SwiftUI

struct FilmListView: View {
    private let repository: FilmRepository

    @StateObject private var viewModel: FilmListViewModel
    private let title = "Star Wars Films"

    init(repository: FilmRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: FilmListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .background(StarWarsColors.background)
                .task {
                    await viewModel.loadFilms()
                }
                .navigationDestination(for: Int.self) { filmId in
                    FilmDetailView(repository: repository, filmId: filmId)
                }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 12) {
                SearchBarView(text: $viewModel.searchQuery, placeholder: "Search by title")

                switch viewModel.uiState {
                case .loading:
                    LoadingView()
                        .frame(maxWidth: .infinity, minHeight: 300)

                case .empty:
                    ContentUnavailableView(
                        "No films",
                        systemImage: "film",
                        description: Text("Try a different search.")
                    )
                    .frame(maxWidth: .infinity, minHeight: 300)

                case .error(let message):
                    ErrorView(message: message) {
                        Task { await viewModel.loadFilms() }
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)

                case .success(let films):
                    LazyVStack(spacing: 12) {
                        ForEach(films) { film in
                            NavigationLink(value: film.id) {
                                FilmCardView(film: film)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteFilm(film)
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
            await viewModel.loadFilms()
        }
    }

    private func deleteFilm(_ film: Film) {
        Task { await viewModel.deleteItem(id: film.id) }
    }
}

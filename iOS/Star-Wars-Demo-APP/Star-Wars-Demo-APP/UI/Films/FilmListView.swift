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
        List {
            SearchBarView(text: $viewModel.searchQuery, placeholder: "Search by title")
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
                    "No films",
                    systemImage: "film",
                    description: Text("Try a different search.")
                )
                .frame(maxWidth: .infinity, minHeight: 300)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            case .error(let message):
                ErrorView(message: message) {
                    Task { await viewModel.loadFilms() }
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            case .success(let films):
                ForEach(films) { film in
                    NavigationLink(value: film.id) {
                        FilmCardView(film: film)
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
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
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            await viewModel.loadFilms()
        }
    }

    private func deleteFilm(_ film: Film) {
        Task { await viewModel.deleteItem(id: film.id) }
    }
}

import SwiftUI

struct FilmListView: View {
    private let repository: FilmRepository

    @StateObject private var viewModel: FilmListViewModel

    init(repository: FilmRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: FilmListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                SearchBarView(text: $viewModel.searchQuery)
                content
            }
            .navigationTitle("Star Wars Films")
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

        case .success(let films, let page, let totalPages):
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(films) { film in
                        NavigationLink(value: film.id) {
                            FilmCardView(film: film)
                        }
                        .buttonStyle(.plain)
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

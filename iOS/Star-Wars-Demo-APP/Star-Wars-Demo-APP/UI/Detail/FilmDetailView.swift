import SwiftUI

struct FilmDetailView: View {
    @StateObject private var viewModel: FilmDetailViewModel

    init(repository: FilmRepository, filmId: Int) {
        _viewModel = StateObject(wrappedValue: FilmDetailViewModel(filmId: filmId, repository: repository))
    }

    var body: some View {
        ScrollView {
            switch viewModel.uiState {
            case .loading:
                LoadingView()
                    .frame(maxWidth: .infinity, minHeight: 300)

            case .error(let message):
                ErrorView(message: message) {
                    viewModel.load()
                }
                .frame(maxWidth: .infinity, minHeight: 300)

            case .success(let film):
                VStack(spacing: 12) {
                    headerSection(film)
                    openingCrawlSection(film)
                    infoSection(film)
                    statsSection(film)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 16)
            }
        }
        .background {
            StarWarsColors.background
                .ignoresSafeArea()
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.load()
        }
    }

    private var navigationTitle: String {
        if case .success(let film) = viewModel.uiState {
            return film.title
        }
        return "Film Detail"
    }

    private func headerSection(_ film: Film) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 6) {
                Text("Episode \(film.episodeId.toRomanNumeral())")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(StarWarsColors.primary)

                Text(film.title)
                    .font(.title2.weight(.bold))
            }
        }
    }

    private func openingCrawlSection(_ film: Film) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 8) {
                Text("Opening Crawl")
                    .font(.headline)
                    .foregroundStyle(StarWarsColors.primary)

                Text(film.openingCrawl)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func infoSection(_ film: Film) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 12) {
                Text("Info")
                    .font(.headline)
                    .foregroundStyle(StarWarsColors.primary)

                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                    GridRow { label("Director"); value(film.director) }
                    GridRow { label("Producer"); value(film.producer) }
                    GridRow { label("Release"); value(film.releaseDate) }
                }
            }
        }
    }

    private func statsSection(_ film: Film) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 12) {
                Text("Stats")
                    .font(.headline)
                    .foregroundStyle(StarWarsColors.primary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    statCard("Characters", film.charactersCount)
                    statCard("Planets", film.planetsCount)
                    statCard("Starships", film.starshipsCount)
                    statCard("Vehicles", film.vehiclesCount)
                    statCard("Species", film.speciesCount)
                }
            }
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func value(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statCard(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.title3.weight(.bold))
                .foregroundStyle(StarWarsColors.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(StarWarsColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(StarWarsColors.primary.opacity(0.12))
        }
    }
}

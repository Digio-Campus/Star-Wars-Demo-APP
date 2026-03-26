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
                VStack(alignment: .leading, spacing: 16) {
                    header(film)
                    openingCrawl(film)

                    infoRow(label: "Director", value: film.director)
                    infoRow(label: "Producer", value: film.producer)
                    infoRow(label: "Release", value: film.releaseDate)

                    statsGrid(film)
                }
                .padding()
            }
        }
        .background(StarWarsColors.background)
        .navigationTitle("Film Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.load()
        }
    }

    private func header(_ film: Film) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Episode \(film.episodeId.toRomanNumeral())")
                .font(.caption.weight(.bold))
                .foregroundStyle(StarWarsColors.primary)

            Text(film.title)
                .font(.title2.weight(.bold))
        }
    }

    private func openingCrawl(_ film: Film) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Opening Crawl")
                .font(.headline)
                .foregroundStyle(StarWarsColors.primary)

            Text(film.openingCrawl)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(StarWarsColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .frame(width: 90, alignment: .leading)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
        }
    }

    private func statsGrid(_ film: Film) -> some View {
        VStack(alignment: .leading, spacing: 10) {
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
    }
}

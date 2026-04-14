import SwiftUI

struct StarshipDetailView: View {
    @StateObject private var viewModel: StarshipDetailViewModel

    init(repository: StarshipRepository, starshipId: Int) {
        _viewModel = StateObject(wrappedValue: StarshipDetailViewModel(starshipId: starshipId, repository: repository))
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

            case .success(let starship):
                VStack(spacing: 12) {
                    headerSection(starship)
                    specsSection(starship)
                    statsSection(starship)
                }
                .padding(.vertical, 16)
            }
        }
        .background(StarWarsColors.background)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.load()
        }
    }

    private var navigationTitle: String {
        if case .success(let starship) = viewModel.uiState {
            return starship.name
        }
        return "Starship"
    }

    private func headerSection(_ starship: Starship) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 6) {
                Text(starship.name)
                    .font(.title2.weight(.bold))

                Text(starship.model)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func specsSection(_ starship: Starship) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 12) {
                Text("Specifications")
                    .font(.headline)
                    .foregroundStyle(StarWarsColors.primary)

                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                    GridRow { label("Class"); value(starship.starshipClass) }
                    GridRow { label("Manufacturer"); value(starship.manufacturer) }
                    GridRow { label("Crew"); value(starship.crew) }
                    GridRow { label("Passengers"); value(starship.passengers) }
                    GridRow { label("Cost"); value(starship.costInCredits) }
                    GridRow { label("Hyperdrive"); value(starship.hyperdriveRating) }
                }
            }
        }
    }

    private func statsSection(_ starship: Starship) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 12) {
                Text("Stats")
                    .font(.headline)
                    .foregroundStyle(StarWarsColors.primary)

                LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                    statCard("Films", starship.filmsCount)
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

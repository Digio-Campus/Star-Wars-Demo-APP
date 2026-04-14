import SwiftUI

struct PlanetDetailView: View {
    @StateObject private var viewModel: PlanetDetailViewModel

    init(repository: PlanetRepository, planetId: Int) {
        _viewModel = StateObject(wrappedValue: PlanetDetailViewModel(planetId: planetId, repository: repository))
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

            case .success(let planet):
                VStack(spacing: 12) {
                    headerSection(planet)
                    detailsSection(planet)
                    statsSection(planet)
                }
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
        if case .success(let planet) = viewModel.uiState {
            return planet.name
        }
        return "Planet"
    }

    private func headerSection(_ planet: Planet) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 6) {
                Text(planet.name)
                    .font(.title2.weight(.bold))

                Text("\(planet.climate) · \(planet.terrain)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func detailsSection(_ planet: Planet) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 12) {
                Text("Details")
                    .font(.headline)
                    .foregroundStyle(StarWarsColors.primary)

                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                    GridRow { label("Population"); value(planet.population) }
                    GridRow { label("Diameter"); value(planet.diameter) }
                    GridRow { label("Gravity"); value(planet.gravity) }
                }
            }
        }
    }

    private func statsSection(_ planet: Planet) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 12) {
                Text("Stats")
                    .font(.headline)
                    .foregroundStyle(StarWarsColors.primary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    statCard("Residents", planet.residentsCount)
                    statCard("Films", planet.filmsCount)
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

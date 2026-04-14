import SwiftUI

struct PersonDetailView: View {
    @StateObject private var viewModel: PersonDetailViewModel

    init(repository: PersonRepository, personId: Int) {
        _viewModel = StateObject(wrappedValue: PersonDetailViewModel(personId: personId, repository: repository))
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

            case .success(let person):
                VStack(spacing: 12) {
                    headerSection(person)
                    detailsSection(person)
                    statsSection(person)
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
        if case .success(let person) = viewModel.uiState {
            return person.name
        }
        return "Person"
    }

    private func headerSection(_ person: Person) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 6) {
                Text(person.name)
                    .font(.title2.weight(.bold))

                Text("\(person.gender) · Born \(person.birthYear)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func detailsSection(_ person: Person) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 12) {
                Text("Details")
                    .font(.headline)
                    .foregroundStyle(StarWarsColors.primary)

                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                    GridRow { label("Height"); value(person.height) }
                    GridRow { label("Mass"); value(person.mass) }
                    GridRow { label("Homeworld"); value(person.homeworldURL) }
                }
            }
        }
    }

    private func statsSection(_ person: Person) -> some View {
        FullWidthSection {
            VStack(alignment: .leading, spacing: 12) {
                Text("Stats")
                    .font(.headline)
                    .foregroundStyle(StarWarsColors.primary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    statCard("Films", person.filmsCount)
                    statCard("Starships", person.starshipsCount)
                    statCard("Vehicles", person.vehiclesCount)
                    statCard("Species", person.speciesCount)
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

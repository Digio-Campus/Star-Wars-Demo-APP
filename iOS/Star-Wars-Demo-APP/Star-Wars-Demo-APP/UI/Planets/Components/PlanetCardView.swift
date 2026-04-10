import SwiftUI

struct PlanetCardView: View {
    let planet: Planet

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(planet.name)
                .font(.headline)
                .foregroundStyle(.primary)

            Text("Climate: \(planet.climate) · Terrain: \(planet.terrain)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text("Population: \(planet.population)")
                Spacer()
                Text("Residents: \(planet.residentsCount)")
                Spacer()
                Text("Films: \(planet.filmsCount)")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(StarWarsColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

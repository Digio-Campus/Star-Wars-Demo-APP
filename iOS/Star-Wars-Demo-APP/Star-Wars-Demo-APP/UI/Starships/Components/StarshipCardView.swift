import SwiftUI

struct StarshipCardView: View {
    let starship: Starship

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(starship.name)
                .font(.headline)
                .foregroundStyle(.primary)

            Text("\(starship.model) · \(starship.starshipClass)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text("Crew: \(starship.crew)")
                Spacer()
                Text("Passengers: \(starship.passengers)")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack {
                Text("Hyperdrive: \(starship.hyperdriveRating)")
                Spacer()
                Text("Films: \(starship.filmsCount)")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(StarWarsColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

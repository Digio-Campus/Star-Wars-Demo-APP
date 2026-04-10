import SwiftUI

struct PersonCardView: View {
    let person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(person.name)
                .font(.headline)
                .foregroundStyle(.primary)

            HStack {
                Text("Gender: \(person.gender)")
                Spacer()
                Text("Born: \(person.birthYear)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack {
                Text("Films: \(person.filmsCount)")
                Spacer()
                Text("Starships: \(person.starshipsCount)")
                Spacer()
                Text("Vehicles: \(person.vehiclesCount)")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(StarWarsColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

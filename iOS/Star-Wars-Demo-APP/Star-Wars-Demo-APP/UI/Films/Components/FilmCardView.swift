import SwiftUI

struct FilmCardView: View {
    let film: Film

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Episode \(film.episodeId.toRomanNumeral())")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(StarWarsColors.primary)

                Spacer()

                Text(film.releaseDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(film.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text("Director: \(film.director)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(StarWarsColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

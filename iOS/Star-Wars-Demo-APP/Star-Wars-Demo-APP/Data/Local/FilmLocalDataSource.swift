import Foundation
import SwiftData

actor FilmLocalDataSource {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    private func makeContext() -> ModelContext {
        ModelContext(container)
    }

    func fetchAllFilms() throws -> [FilmSwiftDataModel] {
        let context = makeContext()
        let descriptor = FetchDescriptor<FilmSwiftDataModel>()
        return try context.fetch(descriptor)
    }

    func fetchFilm(byId id: Int) throws -> FilmSwiftDataModel? {
        let context = makeContext()
        let descriptor = FetchDescriptor<FilmSwiftDataModel>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first
    }

    func upsertFilms(_ films: [Film]) throws {
        let context = makeContext()
        for film in films {
            let filmId = film.id
            let existing = try context.fetch(
                FetchDescriptor<FilmSwiftDataModel>(predicate: #Predicate { $0.id == filmId })
            ).first

            if let existing {
                existing.title = film.title
                existing.episodeId = film.episodeId
                existing.openingCrawl = film.openingCrawl
                existing.director = film.director
                existing.producer = film.producer
                existing.releaseDate = film.releaseDate
                existing.charactersCount = film.charactersCount
                existing.planetsCount = film.planetsCount
                existing.starshipsCount = film.starshipsCount
                existing.vehiclesCount = film.vehiclesCount
                existing.speciesCount = film.speciesCount
                existing.lastUpdated = .now
            } else {
                let model = FilmSwiftDataModel(
                    id: film.id,
                    title: film.title,
                    episodeId: film.episodeId,
                    openingCrawl: film.openingCrawl,
                    director: film.director,
                    producer: film.producer,
                    releaseDate: film.releaseDate,
                    charactersCount: film.charactersCount,
                    planetsCount: film.planetsCount,
                    starshipsCount: film.starshipsCount,
                    vehiclesCount: film.vehiclesCount,
                    speciesCount: film.speciesCount,
                    lastUpdated: .now
                )
                context.insert(model)
            }
        }
        try context.save()
    }

    func deleteAllFilms() throws {
        let context = makeContext()
        try context.delete(model: FilmSwiftDataModel.self)
        try context.save()
    }

    func filmCount() throws -> Int {
        let context = makeContext()
        return try context.fetchCount(FetchDescriptor<FilmSwiftDataModel>())
    }
}

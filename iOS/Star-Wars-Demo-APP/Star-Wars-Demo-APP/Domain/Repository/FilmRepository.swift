import Foundation

protocol FilmRepository {
    /// Cache-first read. Does not trigger network.
    func getFilms() async -> Result<[Film], Error>

    /// Always hits network, updates local cache, returns fresh data.
    func refreshFilms() async -> Result<[Film], Error>

    func getFilmById(_ id: Int) async -> Result<Film, Error>
    func refreshFilm(id: Int) async -> Result<Film, Error>
}

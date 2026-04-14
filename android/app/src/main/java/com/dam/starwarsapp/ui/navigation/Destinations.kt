package com.dam.starwarsapp.ui.navigation

object Destinations {
    const val Splash = "splash"

    // Bottom tabs
    const val Films = "films"
    const val Starships = "starships"
    const val Planets = "planets"
    const val People = "people"
    const val Settings = "settings"

    // Details
    const val FilmDetail = "film"
    const val StarshipDetail = "starship"
    const val PlanetDetail = "planet"
    const val PersonDetail = "person"

    const val filmIdArg = "filmId"
    const val starshipIdArg = "starshipId"
    const val planetIdArg = "planetId"
    const val personIdArg = "personId"

    fun filmDetailRoute(filmId: Int): String = "$FilmDetail/$filmId"
    fun starshipDetailRoute(starshipId: Int): String = "$StarshipDetail/$starshipId"
    fun planetDetailRoute(planetId: Int): String = "$PlanetDetail/$planetId"
    fun personDetailRoute(personId: Int): String = "$PersonDetail/$personId"
}

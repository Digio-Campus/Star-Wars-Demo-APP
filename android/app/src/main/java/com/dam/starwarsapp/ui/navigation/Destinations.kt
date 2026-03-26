package com.dam.starwarsapp.ui.navigation

object Destinations {
    const val Splash = "splash"
    const val Films = "films"
    const val FilmDetail = "film"

    const val filmIdArg = "filmId"

    fun filmDetailRoute(filmId: Int): String = "$FilmDetail/$filmId"
}

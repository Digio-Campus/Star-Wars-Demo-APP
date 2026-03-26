package com.dam.starwarsapp.domain.repository

import com.dam.starwarsapp.domain.model.Film
import kotlinx.coroutines.flow.Flow

interface FilmRepository {
    fun observeFilms(): Flow<List<Film>>
    fun observeFilm(id: Int): Flow<Film?>

    /** Offline-first: actualiza Room desde red; UI observa la caché. */
    suspend fun refreshFilms(): Result<Unit>
}

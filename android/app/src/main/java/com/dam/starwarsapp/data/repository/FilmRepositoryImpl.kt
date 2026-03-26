package com.dam.starwarsapp.data.repository

import com.dam.starwarsapp.data.local.FilmDao
import com.dam.starwarsapp.data.mapper.toDomain
import com.dam.starwarsapp.data.mapper.toEntity
import com.dam.starwarsapp.data.remote.SwapiService
import com.dam.starwarsapp.domain.model.Film
import com.dam.starwarsapp.domain.repository.FilmRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import javax.inject.Inject

class FilmRepositoryImpl @Inject constructor(
    private val filmDao: FilmDao,
    private val service: SwapiService,
) : FilmRepository {

    override fun observeFilms(): Flow<List<Film>> = filmDao.observeAll().map { list ->
        list.map { it.toDomain() }
    }

    override fun observeFilm(id: Int): Flow<Film?> = filmDao.observeById(id).map { it?.toDomain() }

    override suspend fun refreshFilms(): Result<Unit> = withContext(Dispatchers.IO) {
        runCatching {
            val entities = service.getFilms().map { it.toEntity() }
            filmDao.upsertAll(entities)
        }
    }
}

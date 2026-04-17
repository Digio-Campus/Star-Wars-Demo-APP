package com.dam.starwarsapp.data.repository

import com.dam.starwarsapp.data.local.StarshipDao
import com.dam.starwarsapp.data.mapper.toDomain
import com.dam.starwarsapp.data.mapper.toEntity
import com.dam.starwarsapp.data.remote.SwapiService
import com.dam.starwarsapp.domain.model.Starship
import com.dam.starwarsapp.domain.repository.StarshipRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import javax.inject.Inject

class StarshipRepositoryImpl @Inject constructor(
    private val dao: StarshipDao,
    private val service: SwapiService,
) : StarshipRepository {

    override fun observeStarships(): Flow<List<Starship>> = dao.observeAll().map { list ->
        list.map { it.toDomain() }
    }

    override fun observeStarship(id: Int): Flow<Starship?> = dao.observeById(id).map { it?.toDomain() }

    override suspend fun refreshStarships(): Result<Unit> = withContext(Dispatchers.IO) {
        runCatching {
            val entities = service.getStarships().map { it.toEntity() }
            dao.upsertAll(entities)
        }
    }

    override suspend fun deleteStarship(id: Int) {
        withContext(Dispatchers.IO) {
            dao.deleteById(id)
        }
    }

}

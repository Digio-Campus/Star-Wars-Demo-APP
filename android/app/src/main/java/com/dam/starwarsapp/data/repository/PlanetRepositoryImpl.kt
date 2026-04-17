package com.dam.starwarsapp.data.repository

import com.dam.starwarsapp.data.local.PlanetDao
import com.dam.starwarsapp.data.mapper.toDomain
import com.dam.starwarsapp.data.mapper.toEntity
import com.dam.starwarsapp.data.remote.SwapiService
import com.dam.starwarsapp.domain.model.Planet
import com.dam.starwarsapp.domain.repository.PlanetRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import javax.inject.Inject

class PlanetRepositoryImpl @Inject constructor(
    private val dao: PlanetDao,
    private val service: SwapiService,
) : PlanetRepository {

    override fun observePlanets(): Flow<List<Planet>> = dao.observeAll().map { list ->
        list.map { it.toDomain() }
    }

    override fun observePlanet(id: Int): Flow<Planet?> = dao.observeById(id).map { it?.toDomain() }

    override suspend fun refreshPlanets(): Result<Unit> = withContext(Dispatchers.IO) {
        runCatching {
            val entities = service.getPlanets().map { it.toEntity() }
            dao.upsertAll(entities)
        }
    }

    override suspend fun deletePlanet(id: Int) {
        withContext(Dispatchers.IO) {
            dao.deleteById(id)
        }
    }

}

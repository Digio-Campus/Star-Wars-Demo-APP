package com.dam.starwarsapp.domain.repository

import com.dam.starwarsapp.domain.model.Planet
import kotlinx.coroutines.flow.Flow

interface PlanetRepository {
    fun observePlanets(): Flow<List<Planet>>
    fun observePlanet(id: Int): Flow<Planet?>
    suspend fun refreshPlanets(): Result<Unit>
}

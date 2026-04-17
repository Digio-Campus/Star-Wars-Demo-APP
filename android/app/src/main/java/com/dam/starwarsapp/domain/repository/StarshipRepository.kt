package com.dam.starwarsapp.domain.repository

import com.dam.starwarsapp.domain.model.Starship
import kotlinx.coroutines.flow.Flow

interface StarshipRepository {
    fun observeStarships(): Flow<List<Starship>>
    fun observeStarship(id: Int): Flow<Starship?>
    suspend fun refreshStarships(): Result<Unit>

    suspend fun deleteStarship(id: Int)

}

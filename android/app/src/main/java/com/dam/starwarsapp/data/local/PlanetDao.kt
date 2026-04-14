package com.dam.starwarsapp.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.dam.starwarsapp.data.local.entity.PlanetEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface PlanetDao {

    @Query("SELECT * FROM planets ORDER BY name ASC")
    fun observeAll(): Flow<List<PlanetEntity>>

    @Query("SELECT * FROM planets WHERE id = :id LIMIT 1")
    fun observeById(id: Int): Flow<PlanetEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(entities: List<PlanetEntity>)
}

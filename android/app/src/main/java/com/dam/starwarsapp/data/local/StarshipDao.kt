package com.dam.starwarsapp.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.dam.starwarsapp.data.local.entity.StarshipEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface StarshipDao {

    @Query("SELECT * FROM starships ORDER BY name ASC")
    fun observeAll(): Flow<List<StarshipEntity>>

    @Query("SELECT * FROM starships WHERE id = :id LIMIT 1")
    fun observeById(id: Int): Flow<StarshipEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(entities: List<StarshipEntity>)
}

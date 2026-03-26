package com.dam.starwarsapp.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.dam.starwarsapp.data.local.entity.FilmEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface FilmDao {

    @Query("SELECT * FROM films ORDER BY episodeId ASC")
    fun observeAll(): Flow<List<FilmEntity>>

    @Query("SELECT * FROM films WHERE id = :id LIMIT 1")
    fun observeById(id: Int): Flow<FilmEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(entities: List<FilmEntity>)
}

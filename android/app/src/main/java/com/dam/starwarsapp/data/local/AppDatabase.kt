package com.dam.starwarsapp.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import com.dam.starwarsapp.data.local.entity.FilmEntity

@Database(
    entities = [FilmEntity::class],
    version = 1,
    exportSchema = false,
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun filmDao(): FilmDao
}

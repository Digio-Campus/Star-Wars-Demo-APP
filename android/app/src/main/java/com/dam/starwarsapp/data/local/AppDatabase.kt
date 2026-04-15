package com.dam.starwarsapp.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import com.dam.starwarsapp.data.local.entity.FilmEntity
import com.dam.starwarsapp.data.local.entity.PersonEntity
import com.dam.starwarsapp.data.local.entity.PlanetEntity
import com.dam.starwarsapp.data.local.entity.StarshipEntity

@Database(
    entities = [
        FilmEntity::class,
        PersonEntity::class,
        PlanetEntity::class,
        StarshipEntity::class,
    ],
    version = 3,
    exportSchema = false,
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun filmDao(): FilmDao
    abstract fun personDao(): PersonDao
    abstract fun planetDao(): PlanetDao
    abstract fun starshipDao(): StarshipDao
}

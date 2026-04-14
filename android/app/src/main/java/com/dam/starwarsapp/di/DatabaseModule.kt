package com.dam.starwarsapp.di

import android.content.Context
import androidx.room.Room
import com.dam.starwarsapp.data.local.AppDatabase
import com.dam.starwarsapp.data.local.FilmDao
import com.dam.starwarsapp.data.local.PersonDao
import com.dam.starwarsapp.data.local.PlanetDao
import com.dam.starwarsapp.data.local.StarshipDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    private const val DB_NAME = "star_wars.db"

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): AppDatabase =
        Room.databaseBuilder(context, AppDatabase::class.java, DB_NAME)
            .fallbackToDestructiveMigration()
            .build()

    @Provides
    fun provideFilmDao(db: AppDatabase): FilmDao = db.filmDao()

    @Provides
    fun providePersonDao(db: AppDatabase): PersonDao = db.personDao()

    @Provides
    fun providePlanetDao(db: AppDatabase): PlanetDao = db.planetDao()

    @Provides
    fun provideStarshipDao(db: AppDatabase): StarshipDao = db.starshipDao()
}

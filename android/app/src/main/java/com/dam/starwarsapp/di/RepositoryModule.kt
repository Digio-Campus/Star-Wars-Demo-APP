package com.dam.starwarsapp.di

import com.dam.starwarsapp.data.repository.FilmRepositoryImpl
import com.dam.starwarsapp.data.repository.PersonRepositoryImpl
import com.dam.starwarsapp.data.repository.PlanetRepositoryImpl
import com.dam.starwarsapp.data.repository.StarshipRepositoryImpl
import com.dam.starwarsapp.data.settings.SettingsRepositoryImpl
import com.dam.starwarsapp.domain.repository.FilmRepository
import com.dam.starwarsapp.domain.repository.PersonRepository
import com.dam.starwarsapp.domain.repository.PlanetRepository
import com.dam.starwarsapp.domain.repository.SettingsRepository
import com.dam.starwarsapp.domain.repository.StarshipRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    abstract fun bindFilmRepository(impl: FilmRepositoryImpl): FilmRepository

    @Binds
    abstract fun bindPersonRepository(impl: PersonRepositoryImpl): PersonRepository

    @Binds
    abstract fun bindPlanetRepository(impl: PlanetRepositoryImpl): PlanetRepository

    @Binds
    abstract fun bindStarshipRepository(impl: StarshipRepositoryImpl): StarshipRepository

    @Binds
    abstract fun bindSettingsRepository(impl: SettingsRepositoryImpl): SettingsRepository
}

package com.dam.starwarsapp.di

import com.dam.starwarsapp.data.repository.FilmRepositoryImpl
import com.dam.starwarsapp.domain.repository.FilmRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    abstract fun bindFilmRepository(impl: FilmRepositoryImpl): FilmRepository
}

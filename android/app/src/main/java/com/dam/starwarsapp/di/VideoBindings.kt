package com.dam.starwarsapp.di

import com.dam.starwarsapp.data.provider.YouTubeProvider
import com.dam.starwarsapp.domain.video.VideoProvider
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class VideoBindings {
    @Binds
    @Singleton
    abstract fun bindVideoProvider(impl: YouTubeProvider): VideoProvider
}

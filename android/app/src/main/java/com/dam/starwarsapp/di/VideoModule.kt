package com.dam.starwarsapp.di

import com.dam.starwarsapp.data.provider.VideoResolverImpl
import com.dam.starwarsapp.domain.video.VideoResolver
import com.dam.starwarsapp.domain.video.VideoProvider
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object VideoModule {

    @Provides
    @Singleton
    fun provideVideoResolver(
        provider: VideoProvider,
    ): VideoResolver = VideoResolverImpl(provider)
}

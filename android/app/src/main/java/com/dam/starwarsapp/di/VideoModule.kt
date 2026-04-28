package com.dam.starwarsapp.di

import com.dam.starwarsapp.data.resolver.VideoResolverImpl
import com.dam.starwarsapp.domain.repository.VideoResolver
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
        youTubeProvider: com.dam.starwarsapp.data.provider.YouTubeProvider,
        vimeoRepository: com.dam.starwarsapp.domain.repository.VimeoRepository,
    ): VideoResolver = VideoResolverImpl(youTubeProvider, vimeoRepository)
}

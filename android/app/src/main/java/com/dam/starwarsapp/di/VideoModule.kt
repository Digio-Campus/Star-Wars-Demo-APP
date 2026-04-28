package com.dam.starwarsapp.di

import com.dam.starwarsapp.data.provider.YouTubeProvider
import com.dam.starwarsapp.data.provider.VimeoProvider
import com.dam.starwarsapp.data.remote.YouTubeService
import com.dam.starwarsapp.domain.video.VideoProvider
import com.dam.starwarsapp.domain.video.VideoResolver
import com.dam.starwarsapp.domain.video.VideoResolverImpl
import com.squareup.moshi.Moshi
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class VideoBindings {
    @Binds
    abstract fun bindVideoResolver(impl: VideoResolverImpl): VideoResolver
}

@Module
@InstallIn(SingletonComponent::class)
object VideoModule {

    private const val YOUTUBE_BASE = "https://www.googleapis.com/youtube/v3/"

    @Provides
    @Singleton
    fun provideYouTubeService(okHttpClient: OkHttpClient, moshi: Moshi): YouTubeService {
        val retrofit = Retrofit.Builder()
            .baseUrl(YOUTUBE_BASE)
            .client(okHttpClient)
            .addConverterFactory(MoshiConverterFactory.create(moshi))
            .build()
        return retrofit.create(YouTubeService::class.java)
    }

    @Provides
    fun provideVideoProviders(youtubeProvider: YouTubeProvider, vimeoProvider: VimeoProvider): List<VideoProvider> =
        listOf(youtubeProvider, vimeoProvider)
}

package com.dam.starwarsapp.di

import com.dam.starwarsapp.data.remote.YouTubeService
import com.squareup.moshi.Moshi
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
object YouTubeModule {
    private const val BASE_URL = "https://www.googleapis.com/youtube/v3/"

    @Provides
    @Singleton
    fun provideYouTubeService(
        okHttpClient: OkHttpClient,
        moshi: Moshi,
    ): YouTubeService {
        return Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(MoshiConverterFactory.create(moshi))
            .build()
            .create(YouTubeService::class.java)
    }

    @Provides
    @Singleton
    fun provideYouTubeProvider(
        service: YouTubeService,
    ): com.dam.starwarsapp.data.provider.YouTubeProvider = com.dam.starwarsapp.data.provider.YouTubeProvider(service)
}


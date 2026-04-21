package com.dam.starwarsapp.di

import com.dam.starwarsapp.BuildConfig
import com.dam.starwarsapp.data.remote.VimeoService
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
object VimeoModule {

    private const val BASE_URL = "https://api.vimeo.com/"

    @Provides
    @Singleton
    fun provideVimeoService(
        okHttpClient: OkHttpClient,
        moshi: Moshi,
    ): VimeoService {
        val vimeoClient = okHttpClient
            .newBuilder()
            .addInterceptor { chain ->
                val requestBuilder = chain.request().newBuilder()
                    .addHeader("Accept", "application/vnd.vimeo.*+json;version=3.4")

                if (BuildConfig.VIMEO_TOKEN.isNotBlank()) {
                    requestBuilder.addHeader("Authorization", "Bearer ${BuildConfig.VIMEO_TOKEN}")
                }

                chain.proceed(requestBuilder.build())
            }
            .build()

        return Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(vimeoClient)
            .addConverterFactory(MoshiConverterFactory.create(moshi))
            .build()
            .create(VimeoService::class.java)
    }
}

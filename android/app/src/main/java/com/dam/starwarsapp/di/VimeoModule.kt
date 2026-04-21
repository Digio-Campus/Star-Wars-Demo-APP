package com.dam.starwarsapp.di

import android.util.Log
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
                val original = chain.request()

                val requestBuilder = original.newBuilder()
                    .addHeader("Accept", "application/vnd.vimeo.*+json;version=3.4")

                if (BuildConfig.VIMEO_TOKEN.isNotBlank()) {
                    requestBuilder.addHeader("Authorization", "Bearer ${BuildConfig.VIMEO_TOKEN}")
                }

                val request = requestBuilder.build()

                if (BuildConfig.DEBUG) {
                    Log.d(TAG, "→ ${request.method} ${request.url}")
                    val headerLines = request.headers.names().sorted().joinToString("\n") { name ->
                        val value = if (name.equals("Authorization", ignoreCase = true)) {
                            "Bearer ${redactToken(BuildConfig.VIMEO_TOKEN)}"
                        } else {
                            request.header(name).orEmpty()
                        }
                        "$name: $value"
                    }
                    Log.d(TAG, "Request headers:\n$headerLines")
                }

                val response = chain.proceed(request)

                if (BuildConfig.DEBUG) {
                    Log.d(TAG, "← ${response.code} ${response.message} (${request.method} ${request.url})")
                    val bodyString = runCatching { response.peekBody(MAX_PEEK_BYTES).string() }.getOrNull()
                    Log.d(TAG, "Response body:\n${bodyString ?: "<null>"}")
                }

                response
            }
            .build()

        return Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(vimeoClient)
            .addConverterFactory(MoshiConverterFactory.create(moshi))
            .build()
            .create(VimeoService::class.java)
    }

    private fun redactToken(token: String): String {
        val t = token.trim()
        if (t.isBlank()) return "<missing>"
        if (t.length <= 10) return "<redacted>"
        return t.take(6) + "…" + t.takeLast(4)
    }

    private const val TAG = "VimeoHttp"
    private const val MAX_PEEK_BYTES = 1024L * 1024L // 1MB
}

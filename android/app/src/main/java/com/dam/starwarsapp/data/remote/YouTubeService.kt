package com.dam.starwarsapp.data.remote

import com.dam.starwarsapp.data.remote.dto.youtube.YouTubeSearchResponseDto
import retrofit2.http.GET
import retrofit2.http.Query

interface YouTubeService {
    @GET("search")
    suspend fun searchVideos(
        @Query("part") part: String,
        @Query("q") q: String,
        @Query("type") type: String,
        @Query("maxResults") maxResults: Int,
        @Query("videoEmbeddable") videoEmbeddable: String,
        @Query("key") apiKey: String,
    ): YouTubeSearchResponseDto
}

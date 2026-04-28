package com.dam.starwarsapp.data.remote

import com.dam.starwarsapp.data.remote.dto.youtube.YouTubeSearchResponseDto
import retrofit2.http.GET
import retrofit2.http.Query

interface YouTubeService {
    @GET("search")
    suspend fun searchVideos(
        @Query("part") part: String = "snippet",
        @Query("q") q: String,
        @Query("type") type: String = "video",
        @Query("maxResults") maxResults: Int = 1,
        @Query("videoEmbeddable") videoEmbeddable: String = "true",
        @Query("key") apiKey: String,
    ): YouTubeSearchResponseDto
}

package com.dam.starwarsapp.data.remote

import com.dam.starwarsapp.data.remote.dto.vimeo.VimeoSearchResponseDto
import com.dam.starwarsapp.data.remote.dto.vimeo.VimeoVideoDetailsDto
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface VimeoService {

    @GET("videos")
    suspend fun searchVideos(
        @Query("query") query: String,
        @Query("per_page") perPage: Int = 1,
        @Query("fields") fields: String = "uri,link,name",
    ): VimeoSearchResponseDto

    @GET("videos/{id}")
    suspend fun getVideoDetails(
        @Path("id") id: String,
        @Query("fields") fields: String = "uri,link,name,play.progressive",
    ): VimeoVideoDetailsDto
}

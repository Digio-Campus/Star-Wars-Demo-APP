package com.dam.starwarsapp.data.remote

import com.dam.starwarsapp.data.remote.dto.FilmDto
import retrofit2.http.GET

interface SwapiService {
    @GET("films")
    suspend fun getFilms(): List<FilmDto>
}

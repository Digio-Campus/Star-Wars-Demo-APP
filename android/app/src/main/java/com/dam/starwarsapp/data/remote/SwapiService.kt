package com.dam.starwarsapp.data.remote

import com.dam.starwarsapp.data.remote.dto.FilmDto
import com.dam.starwarsapp.data.remote.dto.PersonDto
import com.dam.starwarsapp.data.remote.dto.PlanetDto
import com.dam.starwarsapp.data.remote.dto.StarshipDto
import retrofit2.http.GET

interface SwapiService {
    @GET("films")
    suspend fun getFilms(): List<FilmDto>

    @GET("people")
    suspend fun getPeople(): List<PersonDto>

    @GET("planets")
    suspend fun getPlanets(): List<PlanetDto>

    @GET("starships")
    suspend fun getStarships(): List<StarshipDto>
}

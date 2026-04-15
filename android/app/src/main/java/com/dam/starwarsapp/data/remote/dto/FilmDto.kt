package com.dam.starwarsapp.data.remote.dto

import com.squareup.moshi.Json

data class FilmDto(
    val title: String,
    @Json(name = "episode_id") val episodeId: Int,
    @Json(name = "opening_crawl") val openingCrawl: String,
    val director: String,
    val producer: String,
    @Json(name = "release_date") val releaseDate: String,
    val characters: List<String> = emptyList(),
    val planets: List<String> = emptyList(),
    val starships: List<String> = emptyList(),
    val vehicles: List<String> = emptyList(),
    val species: List<String> = emptyList(),
    val created: String,
    val edited: String,
    val url: String,
)

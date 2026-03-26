package com.dam.starwarsapp.domain.model

data class Film(
    val id: Int,
    val title: String,
    val episodeId: Int,
    val openingCrawl: String,
    val director: String,
    val producer: String,
    val releaseDate: String,
    val created: String,
    val edited: String,
    val url: String,
)

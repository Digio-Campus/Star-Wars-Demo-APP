package com.dam.starwarsapp.data.remote.dto

import com.squareup.moshi.Json

data class StarshipDto(
    val name: String,
    val model: String,
    val manufacturer: String,
    @Json(name = "starship_class") val starshipClass: String,
    @Json(name = "cost_in_credits") val costInCredits: String,
    val length: String,
    val crew: String,
    val passengers: String,
    val created: String,
    val edited: String,
    val url: String,
)

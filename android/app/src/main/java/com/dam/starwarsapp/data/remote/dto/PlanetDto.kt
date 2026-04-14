package com.dam.starwarsapp.data.remote.dto

import com.squareup.moshi.Json

data class PlanetDto(
    val name: String,
    val climate: String,
    val terrain: String,
    val gravity: String,
    val population: String,
    val diameter: String,
    @Json(name = "rotation_period") val rotationPeriod: String,
    @Json(name = "orbital_period") val orbitalPeriod: String,
    @Json(name = "surface_water") val surfaceWater: String,
    val created: String,
    val edited: String,
    val url: String,
)

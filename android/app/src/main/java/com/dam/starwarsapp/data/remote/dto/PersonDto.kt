package com.dam.starwarsapp.data.remote.dto

import com.squareup.moshi.Json

data class PersonDto(
    val name: String,
    val gender: String,
    @Json(name = "birth_year") val birthYear: String,
    val height: String,
    val mass: String,
    @Json(name = "hair_color") val hairColor: String,
    @Json(name = "skin_color") val skinColor: String,
    @Json(name = "eye_color") val eyeColor: String,
    val created: String,
    val edited: String,
    val url: String,
)

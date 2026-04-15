package com.dam.starwarsapp.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "starships")
data class StarshipEntity(
    @PrimaryKey val id: Int,
    val name: String,
    val model: String,
    val manufacturer: String,
    val starshipClass: String,
    val costInCredits: String,
    val length: String,
    val crew: String,
    val passengers: String,
    val hyperdriveRating: String,
    val created: String,
    val edited: String,
    val url: String,
)

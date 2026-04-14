package com.dam.starwarsapp.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "planets")
data class PlanetEntity(
    @PrimaryKey val id: Int,
    val name: String,
    val climate: String,
    val terrain: String,
    val gravity: String,
    val population: String,
    val diameter: String,
    val rotationPeriod: String,
    val orbitalPeriod: String,
    val surfaceWater: String,
    val created: String,
    val edited: String,
    val url: String,
)

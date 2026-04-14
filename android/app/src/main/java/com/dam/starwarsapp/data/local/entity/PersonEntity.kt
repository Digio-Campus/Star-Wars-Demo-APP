package com.dam.starwarsapp.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "people")
data class PersonEntity(
    @PrimaryKey val id: Int,
    val name: String,
    val gender: String,
    val birthYear: String,
    val height: String,
    val mass: String,
    val hairColor: String,
    val skinColor: String,
    val eyeColor: String,
    val created: String,
    val edited: String,
    val url: String,
)

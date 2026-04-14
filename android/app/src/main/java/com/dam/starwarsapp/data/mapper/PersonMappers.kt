package com.dam.starwarsapp.data.mapper

import com.dam.starwarsapp.data.local.entity.PersonEntity
import com.dam.starwarsapp.data.remote.dto.PersonDto
import com.dam.starwarsapp.domain.model.Person

private val personIdRegex = Regex("/people/(\\d+)")

internal fun PersonDto.toEntity(): PersonEntity {
    val id = personIdRegex.find(url)?.groupValues?.getOrNull(1)?.toIntOrNull()
        ?: error("Cannot parse person id from url: $url")

    return PersonEntity(
        id = id,
        name = name,
        gender = gender,
        birthYear = birthYear,
        height = height,
        mass = mass,
        hairColor = hairColor,
        skinColor = skinColor,
        eyeColor = eyeColor,
        created = created,
        edited = edited,
        url = url,
    )
}

internal fun PersonEntity.toDomain(): Person = Person(
    id = id,
    name = name,
    gender = gender,
    birthYear = birthYear,
    height = height,
    mass = mass,
    hairColor = hairColor,
    skinColor = skinColor,
    eyeColor = eyeColor,
    created = created,
    edited = edited,
    url = url,
)

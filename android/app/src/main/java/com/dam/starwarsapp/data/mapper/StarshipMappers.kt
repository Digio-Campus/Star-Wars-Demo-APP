package com.dam.starwarsapp.data.mapper

import com.dam.starwarsapp.data.local.entity.StarshipEntity
import com.dam.starwarsapp.data.remote.dto.StarshipDto
import com.dam.starwarsapp.domain.model.Starship

private val starshipIdRegex = Regex("/starships/(\\d+)")

internal fun StarshipDto.toEntity(): StarshipEntity {
    val id = starshipIdRegex.find(url)?.groupValues?.getOrNull(1)?.toIntOrNull()
        ?: error("Cannot parse starship id from url: $url")

    return StarshipEntity(
        id = id,
        name = name,
        model = model,
        manufacturer = manufacturer,
        starshipClass = starshipClass,
        costInCredits = costInCredits,
        length = length,
        crew = crew,
        passengers = passengers,
        hyperdriveRating = hyperdriveRating,
        created = created,
        edited = edited,
        url = url,
    )
}

internal fun StarshipEntity.toDomain(): Starship = Starship(
    id = id,
    name = name,
    model = model,
    manufacturer = manufacturer,
    starshipClass = starshipClass,
    costInCredits = costInCredits,
    length = length,
    crew = crew,
    passengers = passengers,
    hyperdriveRating = hyperdriveRating,
    created = created,
    edited = edited,
    url = url,
)

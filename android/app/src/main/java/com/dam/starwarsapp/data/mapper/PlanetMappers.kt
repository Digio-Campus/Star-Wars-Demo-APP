package com.dam.starwarsapp.data.mapper

import com.dam.starwarsapp.data.local.entity.PlanetEntity
import com.dam.starwarsapp.data.remote.dto.PlanetDto
import com.dam.starwarsapp.domain.model.Planet

private val planetIdRegex = Regex("/planets/(\\d+)")

internal fun PlanetDto.toEntity(): PlanetEntity {
    val id = planetIdRegex.find(url)?.groupValues?.getOrNull(1)?.toIntOrNull()
        ?: error("Cannot parse planet id from url: $url")

    return PlanetEntity(
        id = id,
        name = name,
        climate = climate,
        terrain = terrain,
        gravity = gravity,
        population = population,
        diameter = diameter,
        rotationPeriod = rotationPeriod,
        orbitalPeriod = orbitalPeriod,
        surfaceWater = surfaceWater,
        created = created,
        edited = edited,
        url = url,
    )
}

internal fun PlanetEntity.toDomain(): Planet = Planet(
    id = id,
    name = name,
    climate = climate,
    terrain = terrain,
    gravity = gravity,
    population = population,
    diameter = diameter,
    rotationPeriod = rotationPeriod,
    orbitalPeriod = orbitalPeriod,
    surfaceWater = surfaceWater,
    created = created,
    edited = edited,
    url = url,
)

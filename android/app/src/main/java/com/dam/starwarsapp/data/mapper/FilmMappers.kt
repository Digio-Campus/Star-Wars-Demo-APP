package com.dam.starwarsapp.data.mapper

import com.dam.starwarsapp.data.local.entity.FilmEntity
import com.dam.starwarsapp.data.remote.dto.FilmDto
import com.dam.starwarsapp.domain.model.Film

private val filmIdRegex = Regex("/films/(\\d+)")

internal fun FilmDto.toEntity(): FilmEntity {
    val id = filmIdRegex.find(url)?.groupValues?.getOrNull(1)?.toIntOrNull()
        ?: error("Cannot parse film id from url: $url")

    return FilmEntity(
        id = id,
        title = title,
        episodeId = episodeId,
        openingCrawl = openingCrawl,
        director = director,
        producer = producer,
        releaseDate = releaseDate,
        created = created,
        edited = edited,
        url = url,
    )
}

internal fun FilmEntity.toDomain(): Film = Film(
    id = id,
    title = title,
    episodeId = episodeId,
    openingCrawl = openingCrawl,
    director = director,
    producer = producer,
    releaseDate = releaseDate,
    created = created,
    edited = edited,
    url = url,
)

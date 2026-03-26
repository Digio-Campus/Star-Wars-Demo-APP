package com.dam.starwarsapp.data.mapper

import com.dam.starwarsapp.data.remote.dto.FilmDto
import org.junit.Assert.assertEquals
import org.junit.Test

class FilmMappersTest {

    @Test
    fun `toEntity parses id from url`() {
        val dto = FilmDto(
            title = "A New Hope",
            episodeId = 4,
            openingCrawl = "...",
            director = "George Lucas",
            producer = "Gary Kurtz",
            releaseDate = "1977-05-25",
            created = "2014-12-10T14:23:31.880000Z",
            edited = "2014-12-20T19:49:45.256000Z",
            url = "https://swapi.info/api/films/1",
        )

        val entity = dto.toEntity()

        assertEquals(1, entity.id)
        assertEquals(4, entity.episodeId)
        assertEquals("A New Hope", entity.title)
    }
}

package com.dam.starwarsapp.video

import com.dam.starwarsapp.data.remote.YouTubeService
import com.dam.starwarsapp.data.remote.dto.youtube.YouTubeIdDto
import com.dam.starwarsapp.data.remote.dto.youtube.YouTubeSearchItemDto
import com.dam.starwarsapp.data.remote.dto.youtube.YouTubeSearchResponseDto
import com.dam.starwarsapp.data.remote.dto.youtube.YouTubeSnippetDto
import com.dam.starwarsapp.data.remote.dto.youtube.YouTubeThumbnailDto
import com.dam.starwarsapp.data.remote.dto.youtube.YouTubeThumbnailsDto
import com.dam.starwarsapp.data.provider.YouTubeProvider
import kotlinx.coroutines.runBlocking
import org.junit.Assert.*
import org.junit.Test

class YouTubeProviderTest {
    @Test
    fun `maps search dto to candidate`() = runBlocking {
        val service = object : YouTubeService {
            override suspend fun searchVideos(
                part: String, q: String, type: String, maxResults: Int, 
                videoEmbeddable: String, videoSyndicated: String, apiKey: String
            ): YouTubeSearchResponseDto {
                return YouTubeSearchResponseDto(
                    items = listOf(
                        YouTubeSearchItemDto(
                            id = YouTubeIdDto(videoId = "abc123"),
                            snippet = YouTubeSnippetDto(
                                title = "Test Title",
                                thumbnails = YouTubeThumbnailsDto(
                                    default = YouTubeThumbnailDto(url = "https://img.example/default.jpg")
                                )
                            )
                        )
                    )
                )
            }
            
            override suspend fun videos(part: String, id: String, apiKey: String): com.dam.starwarsapp.data.remote.dto.youtube.YouTubeVideosResponseDto {
                return com.dam.starwarsapp.data.remote.dto.youtube.YouTubeVideosResponseDto(items = emptyList())
            }
        }

        val provider = YouTubeProvider(service)
        val res = provider.search("Test Title")
        assertTrue(res.isSuccess)
        val candidate = res.getOrNull()
        assertNotNull(candidate)
        assertEquals("abc123", candidate?.id)
        assertEquals("https://www.youtube.com/watch?v=abc123", candidate?.watchUrl)
    }
}

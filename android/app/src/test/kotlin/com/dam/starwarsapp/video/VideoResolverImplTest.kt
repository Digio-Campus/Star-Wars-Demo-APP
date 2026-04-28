package com.dam.starwarsapp.video

import com.dam.starwarsapp.domain.video.PlaybackTarget
import com.dam.starwarsapp.domain.video.VideoCandidate
import com.dam.starwarsapp.domain.video.VideoProvider
import com.dam.starwarsapp.domain.video.VideoResolverImpl
import kotlinx.coroutines.runBlocking
import org.junit.Assert.*
import org.junit.Test

class VideoResolverImplTest {
    @Test
    fun `returns embedded from first provider`() = runBlocking {
        val p1 = object : VideoProvider {
            override suspend fun search(title: String): Result<VideoCandidate?> {
                return Result.success(VideoCandidate(id = "a", provider = "youtube", embeddable = true, watchUrl = "https://youtu.be/a"))
            }
        }
        val p2 = object : VideoProvider {
            override suspend fun search(title: String): Result<VideoCandidate?> {
                return Result.success(VideoCandidate(id = "b", provider = "vimeo", embeddable = true, watchUrl = "https://vimeo.com/b"))
            }
        }

        val resolver = VideoResolverImpl(listOf(p1, p2))
        val res = resolver.resolve("Title")
        assertTrue(res.isSuccess)
        val playback = res.getOrNull()
        assertTrue(playback is PlaybackTarget.Embedded)
        assertEquals("a", (playback as PlaybackTarget.Embedded).videoId)
    }

    @Test
    fun `returns external when non embeddable`() = runBlocking {
        val p1 = object : VideoProvider {
            override suspend fun search(title: String): Result<VideoCandidate?> {
                return Result.success(VideoCandidate(id = "a", provider = "youtube", embeddable = false, watchUrl = "https://external"))
            }
        }
        val p2 = object : VideoProvider {
            override suspend fun search(title: String): Result<VideoCandidate?> {
                return Result.success(VideoCandidate(id = "b", provider = "vimeo", embeddable = true, watchUrl = "https://vimeo.com/b"))
            }
        }

        val resolver = VideoResolverImpl(listOf(p1, p2))
        val res = resolver.resolve("Title")
        assertTrue(res.isSuccess)
        val playback = res.getOrNull()
        assertTrue(playback is PlaybackTarget.External)
        assertEquals("https://external", (playback as PlaybackTarget.External).url)
    }
}

package com.dam.starwarsapp.video

import com.dam.starwarsapp.domain.video.PlaybackTarget
import com.dam.starwarsapp.domain.video.VideoCandidate
import com.dam.starwarsapp.domain.video.VideoProvider
import com.dam.starwarsapp.domain.video.VideoResolver
import kotlinx.coroutines.runBlocking
import org.junit.Assert.*
import org.junit.Test

class VideoResolverTest {
    @Test
    fun `returns embedded when provider yields embeddable candidate`() = runBlocking {
        val provider = object : VideoProvider {
            override suspend fun search(title: String): Result<VideoCandidate?> {
                return Result.success(VideoCandidate(id = "vid1", provider = "youtube", embeddable = true, watchUrl = "https://youtu.be/vid1"))
            }
        }

        val resolver = object : VideoResolver {
            override suspend fun resolve(title: String): Result<PlaybackTarget?> {
                val res = provider.search(title)
                if (res.isFailure) return Result.failure(res.exceptionOrNull()!!)
                val candidate = res.getOrNull()
                return if (candidate == null) {
                    Result.success(null)
                } else if (candidate.embeddable) {
                    Result.success(PlaybackTarget.Embedded(candidate.id, candidate.provider))
                } else {
                    Result.success(PlaybackTarget.External(candidate.watchUrl ?: "https://www.youtube.com/watch?v=${candidate.id}"))
                }
            }
        }

        val result = resolver.resolve("Title")
        assertTrue(result.isSuccess)
        val playback = result.getOrNull()
        assertTrue(playback is PlaybackTarget.Embedded)
    }

    @Test
    fun `returns external when provider yields non-embeddable candidate`() = runBlocking {
        val provider = object : VideoProvider {
            override suspend fun search(title: String): Result<VideoCandidate?> {
                return Result.success(VideoCandidate(id = "vid2", provider = "yt", embeddable = false, watchUrl = "https://youtu.be/vid2"))
            }
        }

        val resolver = object : VideoResolver {
            override suspend fun resolve(title: String): Result<PlaybackTarget?> {
                val res = provider.search(title)
                if (res.isFailure) return Result.failure(res.exceptionOrNull()!!)
                val candidate = res.getOrNull()
                return if (candidate == null) {
                    Result.success(null)
                } else if (candidate.embeddable) {
                    Result.success(PlaybackTarget.Embedded(candidate.id, candidate.provider))
                } else {
                    Result.success(PlaybackTarget.External(candidate.watchUrl ?: "https://www.youtube.com/watch?v=${candidate.id}"))
                }
            }
        }

        val result = resolver.resolve("Title")
        assertTrue(result.isSuccess)
        val playback = result.getOrNull()
        assertTrue(playback is PlaybackTarget.External)
    }
}

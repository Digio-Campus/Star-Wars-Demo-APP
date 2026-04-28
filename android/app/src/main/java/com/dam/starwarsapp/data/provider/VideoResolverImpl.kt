package com.dam.starwarsapp.data.provider

import com.dam.starwarsapp.domain.video.PlaybackTarget
import com.dam.starwarsapp.domain.video.VideoProvider
import com.dam.starwarsapp.domain.video.VideoResolver
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class VideoResolverImpl @Inject constructor(
    private val provider: VideoProvider
) : VideoResolver {
    override suspend fun resolve(title: String): Result<PlaybackTarget?> {
        val res = provider.search(title)
        if (res.isFailure) return Result.failure(res.exceptionOrNull()!!)
        val candidate = res.getOrNull()
        return if (candidate == null) {
            Result.success(null)
        } else if (candidate.embeddable) {
            Result.success(PlaybackTarget.Embedded(candidate.id, candidate.provider))
        } else {
            Result.success(PlaybackTarget.External("https://www.youtube.com/watch?v=${candidate.id}"))
        }
    }
}

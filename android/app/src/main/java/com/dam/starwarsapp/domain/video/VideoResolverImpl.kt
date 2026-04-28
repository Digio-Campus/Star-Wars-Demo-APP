package com.dam.starwarsapp.domain.video

import javax.inject.Inject
import kotlin.jvm.JvmSuppressWildcards

class VideoResolverImpl @Inject constructor(
    private val providers: @JvmSuppressWildcards List<VideoProvider>,
) : VideoResolver {
    override suspend fun resolve(title: String): Result<PlaybackTarget?> {
        return try {
            for (provider in providers) {
                val res = provider.search(title)
                if (res.isFailure) continue
                val candidate = res.getOrNull()
                if (candidate == null) continue
                return if (candidate.embeddable) {
                    Result.success(PlaybackTarget.Embedded(candidate.id, candidate.provider))
                } else {
                    Result.success(PlaybackTarget.External(candidate.watchUrl ?: "https://www.youtube.com/watch?v=${candidate.id}"))
                }
            }
            Result.success(null)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

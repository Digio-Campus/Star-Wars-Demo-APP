package com.dam.starwarsapp.domain.video

/**
 * Provider contract used by the VideoResolver in domain.video.
 * Returns a Result wrapping a nullable VideoCandidate to encode errors.
 */
interface VideoProvider {
    suspend fun search(title: String): Result<VideoCandidate?>
}

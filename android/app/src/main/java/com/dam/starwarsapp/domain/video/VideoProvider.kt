package com.dam.starwarsapp.domain.video

/**
 * Provider contract for searching videos (YouTube, Vimeo, ...).
 * Implementations should return a Kotlin Result containing a VideoCandidate when found,
 * or a failure when an exception occurred.
 */
interface VideoProvider {
    suspend fun search(title: String): Result<VideoCandidate?>
}

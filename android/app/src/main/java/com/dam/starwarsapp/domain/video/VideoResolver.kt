package com.dam.starwarsapp.domain.video

/**
 * High-level resolver that can consult multiple providers to produce a PlaybackTarget.
 */
interface VideoResolver {
    suspend fun resolve(title: String): Result<PlaybackTarget?>
}

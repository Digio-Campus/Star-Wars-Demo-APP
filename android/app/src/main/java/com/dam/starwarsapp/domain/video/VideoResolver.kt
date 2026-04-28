package com.dam.starwarsapp.domain.video

/**
 * Orchestrator contract returning a Result-wrapped PlaybackTarget (may be null if no video found).
 */
interface VideoResolver {
    suspend fun resolve(title: String): Result<PlaybackTarget?>
}

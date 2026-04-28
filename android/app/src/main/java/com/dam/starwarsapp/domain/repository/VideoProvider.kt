package com.dam.starwarsapp.domain.repository

import com.dam.starwarsapp.domain.model.VideoCandidate
import com.dam.starwarsapp.domain.model.PlaybackTarget

/**
 * Provider abstraction for searching and resolving videos.
 */
interface VideoProvider {
    val id: String
    suspend fun searchFirst(title: String): VideoCandidate?
    suspend fun resolvePlayback(candidate: VideoCandidate): PlaybackTarget?
}

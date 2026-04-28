package com.dam.starwarsapp.domain.video

/**
 * Represents a candidate video returned by a provider (YouTube, Vimeo, etc.).
 */
data class VideoCandidate(
    val id: String,
    val title: String,
    val provider: String,
    val embeddable: Boolean = true
)

package com.dam.starwarsapp.domain.video

/**
 * Represents a candidate video returned by a provider (YouTube, Vimeo, etc.).
 */
data class VideoCandidate(
    val id: String,
    val provider: String,
    val embeddable: Boolean = true,
    val watchUrl: String? = null,
    val streamUrl: String? = null,
)

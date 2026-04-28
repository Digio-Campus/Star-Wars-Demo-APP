package com.dam.starwarsapp.domain.video

/**
 * Minimal candidate returned by providers in the `domain.video` contract.
 */
data class VideoCandidate(
    val id: String,
    val provider: String,
    val title: String? = null,
    val embeddable: Boolean = true,
    val watchUrl: String? = null,
    val thumbnailUrl: String? = null,
)

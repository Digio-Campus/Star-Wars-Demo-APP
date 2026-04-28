package com.dam.starwarsapp.domain.model

/**
 * A generic candidate returned by a video provider when searching for a title.
 */
data class VideoCandidate(
    val provider: String,
    val contentId: String,
    val title: String,
    val watchUrl: String,
    val thumbnailUrl: String? = null,
)

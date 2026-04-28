package com.dam.starwarsapp.domain.model

/**
 * Where and how a video should be played.
 */
sealed class PlaybackTarget {
    data class Embedded(val url: String) : PlaybackTarget()
    data class DirectStream(val url: String) : PlaybackTarget()
    data class External(val url: String) : PlaybackTarget()
}

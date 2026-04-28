package com.dam.starwarsapp.domain.video

/**
 * How a video should be played back in the app.
 */
sealed class PlaybackTarget {
    data class Embedded(val videoId: String, val provider: String) : PlaybackTarget()
    data class External(val url: String) : PlaybackTarget()
}

package com.dam.starwarsapp.domain.video

sealed class PlaybackTarget {
    data class Embedded(val id: String, val provider: String) : PlaybackTarget()
    data class External(val url: String) : PlaybackTarget()
}

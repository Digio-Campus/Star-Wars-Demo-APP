package com.dam.starwarsapp.domain.video

interface TrailerPlayer {
    suspend fun load(source: VideoSource)
    fun play()
    fun pause()
    fun release()
    fun enableCasting()
}

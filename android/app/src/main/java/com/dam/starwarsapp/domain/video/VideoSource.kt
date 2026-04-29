package com.dam.starwarsapp.domain.video

sealed class VideoSource {
    data class YouTube(val videoId: String) : VideoSource()
    data class Vimeo(val videoId: String) : VideoSource()
    data class Direct(val url: String) : VideoSource()
}

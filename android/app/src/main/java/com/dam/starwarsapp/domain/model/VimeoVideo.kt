package com.dam.starwarsapp.domain.model

data class VimeoVideo(
    val uri: String,
    val link: String,
    val name: String,
    val playbackUrl: String? = null,
)

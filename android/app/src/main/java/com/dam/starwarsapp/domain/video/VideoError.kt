package com.dam.starwarsapp.domain.video

/**
 * Errors that can occur while resolving/searching videos.
 */
sealed class VideoError {
    object NotFound : VideoError()
    data class Network(val message: String) : VideoError()
    data class Parsing(val message: String) : VideoError()
    data class Unknown(val throwable: Throwable) : VideoError()
}

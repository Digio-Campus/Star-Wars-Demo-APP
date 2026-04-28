package com.dam.starwarsapp.domain.model

/**
 * A resolved video contains the provider candidate and the playback target to use in UI.
 */
data class ResolvedVideo(
    val candidate: VideoCandidate,
    val playbackTarget: PlaybackTarget,
)

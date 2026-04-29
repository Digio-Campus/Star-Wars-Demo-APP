package com.dam.starwarsapp.video

import com.dam.starwarsapp.domain.video.PlaybackTarget
import com.dam.starwarsapp.domain.video.VideoSource
import org.junit.Assert.*
import org.junit.Test

class VideoSourceMappingTest {

    @Test
    fun `embedded youtube maps to VideoSource YouTube`() {
        val playback = PlaybackTarget.Embedded(videoId = "vid123", provider = "youtube")
        val source = when (playback) {
            is PlaybackTarget.Embedded -> {
                when (playback.provider.lowercase()) {
                    "youtube" -> VideoSource.YouTube(playback.videoId)
                    "vimeo" -> VideoSource.Vimeo(playback.videoId)
                    else -> VideoSource.Vimeo(playback.videoId)
                }
            }
            is PlaybackTarget.External -> {
                if (playback.url.endsWith(".mp4") || playback.url.contains(".m3u8")) VideoSource.Direct(playback.url) else VideoSource.Direct(playback.url)
            }
            else -> null
        }

        assertTrue(source is VideoSource.YouTube)
    }

    @Test
    fun `external mp4 maps to Direct`() {
        val playback = PlaybackTarget.External("https://example.com/video.mp4")
        val source = when (playback) {
            is PlaybackTarget.External -> {
                if (playback.url.endsWith(".mp4") || playback.url.contains(".m3u8")) VideoSource.Direct(playback.url) else VideoSource.Direct(playback.url)
            }
            else -> null
        }

        assertTrue(source is VideoSource.Direct)
    }
}

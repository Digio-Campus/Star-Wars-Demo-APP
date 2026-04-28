package com.dam.starwarsapp.data.provider

import com.dam.starwarsapp.BuildConfig
import com.dam.starwarsapp.data.remote.YouTubeService
import com.dam.starwarsapp.domain.model.VideoCandidate
import com.dam.starwarsapp.domain.model.PlaybackTarget
import com.dam.starwarsapp.domain.repository.VideoProvider
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class YouTubeProvider @Inject constructor(
    private val service: YouTubeService,
) : VideoProvider {
    override val id: String = "youtube"

    override suspend fun searchFirst(title: String): VideoCandidate? {
        val q = title.trim().replace(Regex("\\s+"), " ")
        if (q.isBlank()) return null
        val response = service.searchVideos(q = q, apiKey = BuildConfig.YOUTUBE_API_KEY)
        val item = response.items.firstOrNull() ?: return null
        val videoId = item.id?.videoId ?: return null
        val watchUrl = "https://www.youtube.com/watch?v=$videoId"
        val thumbnail = item.snippet?.thumbnails?.high?.url ?: item.snippet?.thumbnails?.default?.url
        return VideoCandidate(
            provider = id,
            contentId = videoId,
            title = item.snippet?.title ?: "",
            watchUrl = watchUrl,
            thumbnailUrl = thumbnail,
        )
    }

    override suspend fun resolvePlayback(candidate: VideoCandidate): PlaybackTarget? {
        if (candidate.provider != id) return null
        val embedUrl = "https://www.youtube.com/embed/${candidate.contentId}"
        return PlaybackTarget.Embedded(embedUrl)
    }
}

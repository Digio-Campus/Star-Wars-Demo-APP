package com.dam.starwarsapp.data.provider

import com.dam.starwarsapp.BuildConfig
import com.dam.starwarsapp.data.remote.YouTubeService
import com.dam.starwarsapp.domain.video.VideoCandidate
import com.dam.starwarsapp.domain.video.VideoProvider

class YouTubeProvider(
    private val service: YouTubeService,
) : VideoProvider {

    override suspend fun search(title: String): Result<VideoCandidate?> {
        return try {
            val q = title.trim().replace(Regex("\\s+"), " ")
            if (q.isBlank()) return Result.success(null)

            val response = service.searchVideos(q = q, apiKey = BuildConfig.YOUTUBE_API_KEY)
            val item = response.items.firstOrNull() ?: return Result.success(null)
            val videoId = item.id?.videoId ?: return Result.success(null)
            val watchUrl = "https://www.youtube.com/watch?v=$videoId"
            val thumbnail = item.snippet?.thumbnails?.high?.url ?: item.snippet?.thumbnails?.default?.url

            val candidate = VideoCandidate(
                id = videoId,
                provider = "youtube",
                title = item.snippet?.title,
                embeddable = true,
                watchUrl = watchUrl,
                thumbnailUrl = thumbnail,
            )

            Result.success(candidate)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

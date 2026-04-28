package com.dam.starwarsapp.data.provider

import com.dam.starwarsapp.BuildConfig
import com.dam.starwarsapp.data.remote.YouTubeService
import com.dam.starwarsapp.domain.video.VideoCandidate
import com.dam.starwarsapp.domain.video.VideoProvider
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class YouTubeProvider @Inject constructor(
    private val service: YouTubeService,
) : VideoProvider {
    override suspend fun search(title: String): Result<VideoCandidate?> {
        return try {
            val resp = service.searchVideos(
                part = "snippet",
                q = title,
                type = "video",
                maxResults = 1,
                videoEmbeddable = "true",
                apiKey = BuildConfig.YOUTUBE_API_KEY,
            )
            val item = resp.items.firstOrNull()
            val id = item?.id?.videoId ?: return Result.success(null)
            val watchUrl = "https://www.youtube.com/watch?v=$id"
            val candidate = VideoCandidate(id = id, provider = "youtube", embeddable = true, watchUrl = watchUrl)
            Result.success(candidate)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

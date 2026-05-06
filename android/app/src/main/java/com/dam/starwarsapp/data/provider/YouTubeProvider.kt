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
            val apiKey = BuildConfig.YOUTUBE_API_KEY.trim()
            if (apiKey.isBlank()) return Result.success(null)

            val normalized = title.trim()
            if (normalized.isBlank()) return Result.success(null)

            val baseQuery = if (normalized.contains("star wars", ignoreCase = true)) normalized else "Star Wars $normalized"
            val trailerQuery = if (baseQuery.contains("trailer", ignoreCase = true)) baseQuery else "$baseQuery trailer"
            val query = "$trailerQuery official"

            val resp = service.searchVideos(
                part = "snippet",
                q = query,
                type = "video",
                maxResults = 10,
                videoEmbeddable = "true",
                videoSyndicated = "true",
                apiKey = apiKey,
            )

            val ids = resp.items.mapNotNull { it.id?.videoId }.distinct().take(50)
            if (ids.isEmpty()) return Result.success(null)

            val fallbackId = ids.first()
            val fallbackWatchUrl = "https://youtu.be/$fallbackId"

            // Validate candidates using videos.list to avoid age-restricted / non-embeddable videos.
            // If this call fails (quota, etc.), we still return the first search match.
            val details = runCatching {
                service.videos(
                    part = "status,contentDetails",
                    id = ids.joinToString(","),
                    apiKey = apiKey,
                )
            }.getOrNull()

            if (details == null) {
                return Result.success(
                    VideoCandidate(
                        id = fallbackId,
                        provider = "youtube",
                        embeddable = true,
                        watchUrl = fallbackWatchUrl,
                    ),
                )
            }

            val byId = details.items.associateBy { it.id }

            fun isValidEmbeddable(id: String): Boolean {
                val d = byId[id] ?: return false
                val embeddable = d.status?.embeddable == true
                val privacyOk = d.status?.privacyStatus?.equals("public", ignoreCase = true) ?: true
                val ageRestricted = d.contentDetails?.contentRating?.ytRating == "ytAgeRestricted"
                val regionBlocked = !(d.contentDetails?.regionRestriction?.blocked.isNullOrEmpty())
                return embeddable && privacyOk && !ageRestricted && !regionBlocked
            }

            val selected = ids.firstOrNull(::isValidEmbeddable)
            if (selected != null) {
                return Result.success(
                    VideoCandidate(
                        id = selected,
                        provider = "youtube",
                        embeddable = true,
                        watchUrl = "https://youtu.be/$selected",
                    ),
                )
            }

            // No safe embeddable option found -> mark as non-embeddable so resolver can fall back to other providers.
            return Result.success(
                VideoCandidate(
                    id = fallbackId,
                    provider = "youtube",
                    embeddable = false,
                    watchUrl = fallbackWatchUrl,
                ),
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

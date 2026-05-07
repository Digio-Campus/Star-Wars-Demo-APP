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
            // Excluimos la palabra "official" usando el operador "-" en YouTube para evitar los bloqueos estrictos de Disney
            val query = "$trailerQuery -official"

            val resp = service.searchVideos(
                part = "snippet",
                q = query,
                type = "video",
                maxResults = 10,
                videoEmbeddable = "true",
                videoSyndicated = "true",
                apiKey = apiKey,
            )

            val thumbnailsById = resp.items.associate { 
                it.id?.videoId to (it.snippet?.thumbnails?.high?.url ?: it.snippet?.thumbnails?.medium?.url ?: it.snippet?.thumbnails?.default?.url)
            }
            val ids = resp.items.mapNotNull { it.id?.videoId }.distinct()
            if (ids.isEmpty()) return Result.success(null)

            val fallbackId = ids.first()
            val fallbackWatchUrl = "https://youtu.be/$fallbackId"
            val fallbackThumb = thumbnailsById[fallbackId]

            // Validate candidates using videos.list to avoid age-restricted videos.
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
                        thumbnailUrl = fallbackThumb,
                    ),
                )
            }

            val byId = details.items.associateBy { it.id }

            fun isValid(id: String): Boolean {
                val d = byId[id] ?: return false
                val privacyOk = d.status?.privacyStatus?.equals("public", ignoreCase = true) ?: true
                val ageRestricted = d.contentDetails?.contentRating?.ytRating == "ytAgeRestricted"
                val regionBlocked = !(d.contentDetails?.regionRestriction?.blocked.isNullOrEmpty())
                // Ya no comprobamos 'embeddable' porque vamos a usar la miniatura como fallback universal
                return privacyOk && !ageRestricted && !regionBlocked
            }

            val selected = ids.firstOrNull(::isValid) ?: fallbackId
            
            return Result.success(
                VideoCandidate(
                    id = selected,
                    provider = "youtube",
                    embeddable = true, // Forzamos true para que el resolver lo acepte
                    watchUrl = "https://youtu.be/$selected",
                    thumbnailUrl = thumbnailsById[selected] ?: fallbackThumb,
                ),
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

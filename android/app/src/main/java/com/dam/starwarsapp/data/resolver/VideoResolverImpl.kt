package com.dam.starwarsapp.data.resolver

import com.dam.starwarsapp.data.provider.YouTubeProvider
import com.dam.starwarsapp.domain.model.ResolvedVideo
import com.dam.starwarsapp.domain.model.VideoCandidate
import com.dam.starwarsapp.domain.model.PlaybackTarget
import com.dam.starwarsapp.domain.repository.VideoResolver
import com.dam.starwarsapp.domain.repository.VimeoRepository
import kotlinx.coroutines.flow.firstOrNull
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class VideoResolverImpl @Inject constructor(
    private val youTubeProvider: YouTubeProvider,
    private val vimeoRepository: VimeoRepository,
) : VideoResolver {

    override suspend fun resolve(title: String): ResolvedVideo? {
        val normalized = title.trim().replace(Regex("\\s+"), " ")
        if (normalized.isBlank()) return null

        // Try YouTube first
        val ytCandidate = runCatching { youTubeProvider.searchFirst(normalized) }.getOrNull()
        if (ytCandidate != null) {
            val playback = runCatching { youTubeProvider.resolvePlayback(ytCandidate) }.getOrNull()
            if (playback != null) return ResolvedVideo(candidate = ytCandidate, playbackTarget = playback)
        }

        // Fallback to Vimeo (existing repository)
        val vimeoVideo = try {
            vimeoRepository.searchVimeoVideo(normalized).firstOrNull()
        } catch (e: Exception) {
            null
        }

        if (vimeoVideo != null && !vimeoVideo.playbackUrl.isNullOrBlank()) {
            val candidate = VideoCandidate(
                provider = "vimeo",
                contentId = vimeoVideo.uri ?: "",
                title = vimeoVideo.name ?: "",
                watchUrl = vimeoVideo.link ?: "",
                thumbnailUrl = null,
            )
            val playback = PlaybackTarget.DirectStream(vimeoVideo.playbackUrl!!)
            return ResolvedVideo(candidate = candidate, playbackTarget = playback)
        }

        return null
    }
}

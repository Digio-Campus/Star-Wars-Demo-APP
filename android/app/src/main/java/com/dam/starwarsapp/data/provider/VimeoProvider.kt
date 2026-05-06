package com.dam.starwarsapp.data.provider

import com.dam.starwarsapp.domain.video.VideoCandidate
import com.dam.starwarsapp.domain.video.VideoProvider
import com.dam.starwarsapp.domain.repository.VimeoRepository
import kotlinx.coroutines.flow.firstOrNull
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class VimeoProvider @Inject constructor(
    private val vimeoRepository: VimeoRepository,
) : VideoProvider {
    override suspend fun search(title: String): Result<VideoCandidate?> {
        return try {
            val v = vimeoRepository.searchVimeoVideo(title).firstOrNull()
            if (v == null) return Result.success(null)
            val videoId = v.uri.split('/').lastOrNull() ?: return Result.success(null)
            val watchUrl = if (v.link.isNotBlank()) v.link else "https://vimeo.com/$videoId"
            val streamUrl = v.playbackUrl
            val embeddable = !streamUrl.isNullOrBlank()
            val candidate = VideoCandidate(
                id = videoId,
                provider = "vimeo",
                embeddable = embeddable,
                watchUrl = watchUrl,
                streamUrl = streamUrl,
            )
            Result.success(candidate)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

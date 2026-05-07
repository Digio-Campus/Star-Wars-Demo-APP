package com.dam.starwarsapp.domain.video

import com.dam.starwarsapp.util.AppLog
import javax.inject.Inject
import kotlin.jvm.JvmSuppressWildcards

class VideoResolverImpl @Inject constructor(
    private val providers: @JvmSuppressWildcards List<VideoProvider>,
) : VideoResolver {

    override suspend fun resolve(title: String): Result<PlaybackTarget?> {
        try {
            var bestExternalUrl: String? = null

            for (provider in providers) {
                AppLog.d(TAG, "Trying provider=${provider.javaClass.simpleName} for title=\"$title\"")

                val res = try {
                    provider.search(title)
                } catch (e: Exception) {
                    AppLog.w(TAG, "Provider ${provider.javaClass.simpleName} threw: ${e.message}", e)
                    Result.failure<VideoCandidate?>(e)
                }

                if (res.isFailure) {
                    AppLog.d(TAG, "Provider ${provider.javaClass.simpleName} returned failure")
                    continue
                }

                val candidate = res.getOrNull()
                if (candidate == null) {
                    AppLog.d(TAG, "Provider ${provider.javaClass.simpleName} returned no candidate")
                    continue
                }

                AppLog.d(
                    TAG,
                    "Provider ${provider.javaClass.simpleName} returned candidate=${candidate.id} embeddable=${candidate.embeddable} provider=${candidate.provider}",
                )

                val streamUrl = candidate.streamUrl?.trim().orEmpty()
                if (streamUrl.isNotBlank()) {
                    return Result.success(PlaybackTarget.DirectStream(streamUrl))
                }

                if (candidate.embeddable) {
                    return Result.success(PlaybackTarget.Embedded(candidate.id, candidate.provider, candidate.thumbnailUrl))
                }

                val fallbackExternal = candidate.watchUrl
                    ?: when (candidate.provider.lowercase()) {
                        "youtube" -> "https://www.youtube.com/watch?v=${candidate.id}"
                        "vimeo" -> "https://vimeo.com/${candidate.id}"
                        else -> null
                    }

                if (!fallbackExternal.isNullOrBlank()) {
                    bestExternalUrl = fallbackExternal
                }

                // Not embeddable -> try next provider (e.g. Vimeo) before falling back to external.
            }

            if (!bestExternalUrl.isNullOrBlank()) {
                return Result.success(PlaybackTarget.External(bestExternalUrl!!))
            }

            AppLog.d(TAG, "No provider returned a candidate for title=\"$title\"")
            return Result.success(null)
        } catch (e: Exception) {
            AppLog.w(TAG, "Resolution failed: ${e.message}", e)
            return Result.failure(e)
        }
    }

    private companion object {
        const val TAG = "VideoResolver"
    }
}

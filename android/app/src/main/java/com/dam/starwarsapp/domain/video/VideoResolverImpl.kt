package com.dam.starwarsapp.domain.video

import com.dam.starwarsapp.util.AppLog
import javax.inject.Inject
import kotlin.jvm.JvmSuppressWildcards

class VideoResolverImpl @Inject constructor(
    private val providers: @JvmSuppressWildcards List<VideoProvider>,
) : VideoResolver {

    override suspend fun resolve(title: String): Result<PlaybackTarget?> {
        try {
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

                return if (candidate.embeddable) {
                    Result.success(PlaybackTarget.Embedded(candidate.id, candidate.provider))
                } else {
                    Result.success(
                        PlaybackTarget.External(
                            candidate.watchUrl ?: "https://www.youtube.com/watch?v=${candidate.id}",
                        ),
                    )
                }
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

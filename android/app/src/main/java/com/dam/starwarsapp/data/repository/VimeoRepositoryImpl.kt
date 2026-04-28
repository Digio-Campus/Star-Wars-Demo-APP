package com.dam.starwarsapp.data.repository

import android.util.Log
import com.dam.starwarsapp.BuildConfig
import com.dam.starwarsapp.data.remote.VimeoService
import com.dam.starwarsapp.domain.model.VimeoVideo
import com.dam.starwarsapp.domain.repository.VimeoRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import javax.inject.Inject

class VimeoRepositoryImpl @Inject constructor(
    private val service: VimeoService,
) : VimeoRepository {

    private val cacheMutex = Mutex()
    private val cache = mutableMapOf<String, VimeoVideo?>()

    override fun searchVimeoVideo(filmTitle: String): Flow<VimeoVideo?> = flow {
        val key = filmTitle.trim().lowercase()
        Log.d(TAG, "searchVimeoVideo(title=\"$filmTitle\", key=\"$key\")")

        if (key.isBlank()) {
            Log.w(TAG, "Blank title; skipping Vimeo search")
            emit(null)
            return@flow
        }

        val cached = cacheMutex.withLock { cache[key] }
        val hasKey = cacheMutex.withLock { cache.containsKey(key) }
        if (hasKey) {
            Log.d(TAG, "Cache hit for key=\"$key\" -> ${cached?.uri ?: "<null>"}")
            emit(cached)
            return@flow
        }

        if (BuildConfig.VIMEO_TOKEN.isBlank()) {
            Log.w(TAG, "Vimeo token is missing; cannot search Vimeo")
            throw IllegalStateException("Missing Vimeo access token. Set VIMEO_ACCESS_TOKEN in android/local.properties")
        } else {
            Log.d(TAG, "Vimeo token present (len=${BuildConfig.VIMEO_TOKEN.length}, redacted=${redactToken(BuildConfig.VIMEO_TOKEN)})")
        }

        val search = service.searchVideos(query = filmTitle, perPage = 1)
        Log.d(TAG, "Search parsed: items=${search.data.size}")

        val first = search.data.firstOrNull()
        if (first == null) {
            Log.w(TAG, "No Vimeo results for title=\"$filmTitle\"")
            cacheMutex.withLock { cache[key] = null }
            emit(null)
            return@flow
        }

        Log.d(TAG, "First item parsed: uri=${first.uri}, link=${first.link}, name=${first.name}")

        val uri = first.uri?.takeIf { it.isNotBlank() }
        if (uri == null) {
            Log.w(TAG, "First result has no uri; cannot fetch details")
            cacheMutex.withLock { cache[key] = null }
            emit(null)
            return@flow
        }

        val link = first.link.orEmpty()
        val name = first.name.orEmpty()

        val videoId = extractVideoId(uri)
        Log.d(TAG, "Extracted videoId=${videoId ?: "<null>"} from uri=\"$uri\"")

        val playbackUrl = videoId
            ?.let { id ->
                val details = service.getVideoDetails(id)
                val progressive = details.play?.progressive.orEmpty()
                Log.d(TAG, "Details parsed: play.progressive count=${progressive.size}")

                val selected = progressive
                    .filter { !it.link.isNullOrBlank() }
                    .maxByOrNull { it.height ?: 0 }

                if (selected == null) {
                    Log.w(TAG, "No progressive playback links available for videoId=$id")
                    null
                } else {
                    Log.d(
                        TAG,
                        "Selected progressive: height=${selected.height}, quality=${selected.quality}, mime=${selected.mime}, type=${selected.type}, link=${selected.link}",
                    )
                    selected.link
                }
            }

        Log.d(TAG, "Final VimeoVideo: uri=\"$uri\", link=\"$link\", name=\"$name\", playbackUrl=${playbackUrl ?: "<null>"}")

        val result = VimeoVideo(
            uri = uri,
            link = link,
            name = name,
            playbackUrl = playbackUrl,
        )

        cacheMutex.withLock { cache[key] = result }
        emit(result)
    }.flowOn(Dispatchers.IO)

    private fun redactToken(token: String): String {
        val t = token.trim()
        if (t.isBlank()) return "<missing>"
        if (t.length <= 10) return "<redacted>"
        return t.take(6) + "…" + t.takeLast(4)
    }

    private fun extractVideoId(uri: String): String? {
        // Expected: "/videos/{id}" (e.g. "/videos/123456789")
        return uri
            .split('/')
            .lastOrNull()
            ?.trim()
            ?.takeIf { it.isNotBlank() }
    }

    private companion object {
        const val TAG = "VimeoRepository"
    }
}

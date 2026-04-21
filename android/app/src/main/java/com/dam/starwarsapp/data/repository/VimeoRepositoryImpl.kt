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
        if (key.isBlank()) {
            emit(null)
            return@flow
        }

        val cached = cacheMutex.withLock { cache[key] }
        val hasKey = cacheMutex.withLock { cache.containsKey(key) }
        if (hasKey) {
            emit(cached)
            return@flow
        }

        if (BuildConfig.VIMEO_TOKEN.isBlank()) {
            Log.w(TAG, "Vimeo token is missing; skipping video search")
            cacheMutex.withLock { cache[key] = null }
            emit(null)
            return@flow
        }

        val result = runCatching {
            val first = service.searchVideos(query = filmTitle, perPage = 1).data.firstOrNull()
                ?: return@runCatching null

            val uri = first.uri?.takeIf { it.isNotBlank() } ?: return@runCatching null
            val link = first.link.orEmpty()
            val name = first.name.orEmpty()

            val playbackUrl = extractVideoId(uri)
                ?.let { videoId ->
                    val details = service.getVideoDetails(videoId)
                    details.play
                        ?.progressive
                        ?.filter { !it.link.isNullOrBlank() }
                        ?.maxByOrNull { it.height ?: 0 }
                        ?.link
                }

            VimeoVideo(
                uri = uri,
                link = link,
                name = name,
                playbackUrl = playbackUrl,
            )
        }.getOrElse { e ->
            Log.e(TAG, "Failed to search Vimeo video for title=\"$filmTitle\"", e)
            null
        }

        cacheMutex.withLock { cache[key] = result }
        emit(result)
    }.flowOn(Dispatchers.IO)

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

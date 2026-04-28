package com.dam.starwarsapp.ui.screens.detail

import android.util.Log
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dam.starwarsapp.domain.model.Film
import com.dam.starwarsapp.domain.model.VimeoVideo
import com.dam.starwarsapp.domain.repository.FilmRepository
import com.dam.starwarsapp.domain.repository.VimeoRepository
import com.dam.starwarsapp.ui.navigation.Destinations
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import retrofit2.HttpException
import javax.inject.Inject

@HiltViewModel
class FilmDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    repository: FilmRepository,
    private val vimeoRepository: VimeoRepository,
) : ViewModel() {

    private val filmId: Int = checkNotNull(savedStateHandle[Destinations.filmIdArg])
    private val filmFlow = repository.observeFilm(filmId)

    val uiState: StateFlow<FilmDetailUiState> = filmFlow
        .map { film -> FilmDetailUiState(film = film) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), FilmDetailUiState())

    private val _vimeoVideo = MutableStateFlow<VimeoVideo?>(null)
    val vimeoVideo: StateFlow<VimeoVideo?> = _vimeoVideo.asStateFlow()

    private val _isVimeoLoading = MutableStateFlow(false)
    val isVimeoLoading: StateFlow<Boolean> = _isVimeoLoading.asStateFlow()

    private val _vimeoErrorMessage = MutableStateFlow<String?>(null)
    val vimeoErrorMessage: StateFlow<String?> = _vimeoErrorMessage.asStateFlow()

    private var vimeoJob: Job? = null

    init {
        Log.d(TAG, "FilmDetailViewModel init (filmId=$filmId)")
        viewModelScope.launch {
            filmFlow
                .map { it?.title?.trim().orEmpty() }
                .distinctUntilChanged()
                .collectLatest { title ->
                    Log.d(TAG, "Film title observed: \"$title\"")
                    if (title.isBlank()) {
                        Log.w(TAG, "Blank film title -> clearing Vimeo state")
                        _vimeoVideo.value = null
                        _isVimeoLoading.value = false
                    } else {
                        loadVimeoVideo(title)
                    }
                }
        }
    }

    fun loadVimeoVideo(title: String) {
        Log.d(TAG, "loadVimeoVideo(title=\"$title\")")
        vimeoJob?.cancel()
        vimeoJob = viewModelScope.launch {
            _isVimeoLoading.value = true
            _vimeoErrorMessage.value = null

            val result = vimeoRepository.safeSearch(title)
            Log.d(TAG, "Vimeo search completed. uri=${result?.uri ?: "<null>"} playbackUrl=${result?.playbackUrl ?: "<null>"}")
            _vimeoVideo.value = result
            _isVimeoLoading.value = false
        }
    }

    private suspend fun VimeoRepository.safeSearch(title: String): VimeoVideo? {
        return try {
            searchVimeoVideo(title).firstOrNull()
        } catch (e: IllegalStateException) {
            Log.w(TAG, "Vimeo config error: ${e.message}")
            _vimeoErrorMessage.value = e.message
            null
        } catch (e: HttpException) {
            val message = "Vimeo request failed (HTTP ${e.code()})"
            Log.w(TAG, message, e)
            _vimeoErrorMessage.value = message
            null
        } catch (e: Exception) {
            Log.e(TAG, "Vimeo search failed", e)
            _vimeoErrorMessage.value = e.message ?: "Vimeo request failed"
            null
        }
    }

    private companion object {
        const val TAG = "FilmDetailVM"
    }
}

data class FilmDetailUiState(
    val film: Film? = null,
)

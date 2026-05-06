package com.dam.starwarsapp.ui.screens.detail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dam.starwarsapp.domain.model.Film
import com.dam.starwarsapp.domain.repository.FilmRepository
import com.dam.starwarsapp.domain.video.PlaybackTarget
import com.dam.starwarsapp.domain.video.VideoResolver
import com.dam.starwarsapp.ui.navigation.Destinations
import com.dam.starwarsapp.util.AppLog
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class FilmDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    repository: FilmRepository,
    private val videoResolver: VideoResolver,
) : ViewModel() {

    private val filmId: Int = checkNotNull(savedStateHandle[Destinations.filmIdArg])
    private val filmFlow = repository.observeFilm(filmId)

    val uiState: StateFlow<FilmDetailUiState> = filmFlow
        .map { film -> FilmDetailUiState(film = film) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), FilmDetailUiState())

    private val _playbackTarget = MutableStateFlow<PlaybackTarget?>(null)
    val playbackTarget: StateFlow<PlaybackTarget?> = _playbackTarget.asStateFlow()

    private val _isVideoLoading = MutableStateFlow(false)
    val isVideoLoading: StateFlow<Boolean> = _isVideoLoading.asStateFlow()

    private val _videoErrorMessage = MutableStateFlow<String?>(null)
    val videoErrorMessage: StateFlow<String?> = _videoErrorMessage.asStateFlow()

    init {
        AppLog.d(TAG, "FilmDetailViewModel init (filmId=$filmId)")
        viewModelScope.launch {
            filmFlow
                .map { it?.title?.trim().orEmpty() }
                .distinctUntilChanged()
                .collectLatest { title ->
                    AppLog.d(TAG, "Film title observed: \"$title\"")
                    if (title.isBlank()) {
                        _playbackTarget.value = null
                        _isVideoLoading.value = false
                        _videoErrorMessage.value = null
                    } else {
                        resolveVideo(title)
                    }
                }
        }
    }

    private fun resolveVideo(title: String) {
        viewModelScope.launch {
            _isVideoLoading.value = true
            _videoErrorMessage.value = null
            try {
                val res = videoResolver.resolve(title)
                _playbackTarget.value = res.getOrNull()
                if (res.isFailure) {
                    _videoErrorMessage.value = res.exceptionOrNull()?.message
                }
            } catch (e: Exception) {
                AppLog.w(TAG, "Video resolution failed: ${e.message}", e)
                _playbackTarget.value = null
                _videoErrorMessage.value = e.message ?: "Video resolution failed"
            } finally {
                _isVideoLoading.value = false
            }
        }
    }

    private companion object {
        const val TAG = "FilmDetailVM"
    }
}

data class FilmDetailUiState(
    val film: Film? = null,
)

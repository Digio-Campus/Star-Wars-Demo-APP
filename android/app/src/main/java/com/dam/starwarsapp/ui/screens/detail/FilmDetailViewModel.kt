package com.dam.starwarsapp.ui.screens.detail

import android.util.Log
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dam.starwarsapp.domain.model.Film
import com.dam.starwarsapp.domain.repository.FilmRepository
import com.dam.starwarsapp.domain.video.PlaybackTarget
import com.dam.starwarsapp.domain.video.VideoResolver
import com.dam.starwarsapp.ui.navigation.Destinations
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

    init {
        Log.d(TAG, "FilmDetailViewModel init (filmId=$filmId)")
        viewModelScope.launch {
            filmFlow
                .map { it?.title?.trim().orEmpty() }
                .distinctUntilChanged()
                .collectLatest { title ->
                    Log.d(TAG, "Film title observed: \"$title\"")
                    if (title.isBlank()) {
                        Log.w(TAG, "Blank film title -> clearing video state")
                        _playbackTarget.value = null
                    } else {
                        val resolved = runCatching { videoResolver.resolve(title) }.getOrNull()
                        _playbackTarget.value = resolved?.getOrNull()
                    }
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

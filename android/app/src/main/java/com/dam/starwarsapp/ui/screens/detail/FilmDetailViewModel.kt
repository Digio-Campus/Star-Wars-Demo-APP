package com.dam.starwarsapp.ui.screens.detail

import android.content.Intent
import android.net.Uri
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

    val uiState: StateFlow<FilmDetailUiState> = repository.observeFilm(filmId)
        .map { film -> FilmDetailUiState(film = film) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), FilmDetailUiState())

    private val _playbackTarget = MutableStateFlow<PlaybackTarget?>(null)
    val playbackTarget: StateFlow<PlaybackTarget?> = _playbackTarget.asStateFlow()

    init {
        viewModelScope.launch {
            repository.observeFilm(filmId).collect { film ->
                if (film != null) {
                    val res = videoResolver.resolve(film.title)
                    _playbackTarget.value = res.getOrNull()
                } else {
                    _playbackTarget.value = null
                }
            }
        }
    }
}

data class FilmDetailUiState(
    val film: Film? = null,
)

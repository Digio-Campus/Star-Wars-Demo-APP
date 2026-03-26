package com.dam.starwarsapp.ui.screens.detail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dam.starwarsapp.domain.model.Film
import com.dam.starwarsapp.domain.repository.FilmRepository
import com.dam.starwarsapp.ui.navigation.Destinations
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

@HiltViewModel
class FilmDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    repository: FilmRepository,
) : ViewModel() {

    private val filmId: Int = checkNotNull(savedStateHandle[Destinations.filmIdArg])

    val uiState: StateFlow<FilmDetailUiState> = repository.observeFilm(filmId)
        .map { film -> FilmDetailUiState(film = film) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), FilmDetailUiState())
}

data class FilmDetailUiState(
    val film: Film? = null,
)

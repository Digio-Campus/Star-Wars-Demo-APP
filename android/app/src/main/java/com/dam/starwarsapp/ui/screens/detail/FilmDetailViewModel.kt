package com.dam.starwarsapp.ui.screens.detail

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

    private var vimeoJob: Job? = null

    init {
        viewModelScope.launch {
            filmFlow
                .map { it?.title?.trim().orEmpty() }
                .distinctUntilChanged()
                .collectLatest { title ->
                    if (title.isBlank()) {
                        _vimeoVideo.value = null
                        _isVimeoLoading.value = false
                    } else {
                        loadVimeoVideo(title)
                    }
                }
        }
    }

    fun loadVimeoVideo(title: String) {
        vimeoJob?.cancel()
        vimeoJob = viewModelScope.launch {
            _isVimeoLoading.value = true
            _vimeoVideo.value = vimeoRepository.searchVimeoVideo(title).firstOrNull()
            _isVimeoLoading.value = false
        }
    }
}

data class FilmDetailUiState(
    val film: Film? = null,
)

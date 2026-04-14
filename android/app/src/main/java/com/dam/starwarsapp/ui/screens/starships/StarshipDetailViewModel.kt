package com.dam.starwarsapp.ui.screens.starships

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dam.starwarsapp.domain.model.Starship
import com.dam.starwarsapp.domain.repository.StarshipRepository
import com.dam.starwarsapp.ui.navigation.Destinations
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

@HiltViewModel
class StarshipDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    repository: StarshipRepository,
) : ViewModel() {

    private val starshipId: Int = checkNotNull(savedStateHandle[Destinations.starshipIdArg])

    val uiState: StateFlow<StarshipDetailUiState> = repository.observeStarship(starshipId)
        .map { starship -> StarshipDetailUiState(starship = starship) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), StarshipDetailUiState())
}

data class StarshipDetailUiState(
    val starship: Starship? = null,
)

package com.dam.starwarsapp.ui.screens.planets

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dam.starwarsapp.domain.model.Planet
import com.dam.starwarsapp.domain.repository.PlanetRepository
import com.dam.starwarsapp.ui.navigation.Destinations
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

@HiltViewModel
class PlanetDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    repository: PlanetRepository,
) : ViewModel() {

    private val planetId: Int = checkNotNull(savedStateHandle[Destinations.planetIdArg])

    val uiState: StateFlow<PlanetDetailUiState> = repository.observePlanet(planetId)
        .map { planet -> PlanetDetailUiState(planet = planet) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), PlanetDetailUiState())
}

data class PlanetDetailUiState(
    val planet: Planet? = null,
)

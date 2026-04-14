package com.dam.starwarsapp.ui.screens.people

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dam.starwarsapp.domain.model.Person
import com.dam.starwarsapp.domain.repository.PersonRepository
import com.dam.starwarsapp.ui.navigation.Destinations
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

@HiltViewModel
class PersonDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    repository: PersonRepository,
) : ViewModel() {

    private val personId: Int = checkNotNull(savedStateHandle[Destinations.personIdArg])

    val uiState: StateFlow<PersonDetailUiState> = repository.observePerson(personId)
        .map { person -> PersonDetailUiState(person = person) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), PersonDetailUiState())
}

data class PersonDetailUiState(
    val person: Person? = null,
)

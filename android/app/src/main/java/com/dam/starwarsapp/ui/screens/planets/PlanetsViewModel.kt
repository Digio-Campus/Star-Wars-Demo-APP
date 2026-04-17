package com.dam.starwarsapp.ui.screens.planets

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dam.starwarsapp.domain.model.Planet
import com.dam.starwarsapp.domain.repository.PlanetRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class PlanetsViewModel @Inject constructor(
    private val repository: PlanetRepository,
) : ViewModel() {

    private val pageSize = 15

    private val query = MutableStateFlow("")
    private val visibleCount = MutableStateFlow(pageSize)

    private val isRefreshing = MutableStateFlow(false)
    private val isLoadingMore = MutableStateFlow(false)
    private val refreshError = MutableStateFlow<String?>(null)

    private val planets: StateFlow<List<Planet>> = repository.observePlanets()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    private val loadingState = combine(
        isRefreshing,
        isLoadingMore,
        refreshError,
    ) { refreshing, loadingMore, error ->
        Triple(refreshing, loadingMore, error)
    }

    val uiState: StateFlow<PlanetsUiState> = combine(
        planets,
        query,
        visibleCount,
        loadingState,
    ) { all, q, visible, loading ->
        val (refreshing, loadingMore, error) = loading

        val normalizedQuery = q.trim()
        val filtered = if (normalizedQuery.isBlank()) all else all.filter {
            it.name.contains(normalizedQuery, ignoreCase = true)
        }

        val safeVisible = visible.coerceAtLeast(pageSize).coerceAtMost(filtered.size)
        val items = filtered.take(safeVisible)

        PlanetsUiState(
            query = q,
            totalResults = filtered.size,
            planets = items,
            isRefreshing = refreshing,
            isLoadingMore = loadingMore,
            canLoadMore = safeVisible < filtered.size,
            refreshError = error,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), PlanetsUiState())

    init {
        loadPlanets()
    }

    fun onQueryChange(newQuery: String) {
        query.value = newQuery
        visibleCount.value = pageSize
    }

    fun loadMore() {
        val state = uiState.value
        if (!state.canLoadMore || state.isLoadingMore) return

        viewModelScope.launch {
            isLoadingMore.value = true
            delay(250)
            visibleCount.value = visibleCount.value + pageSize
            isLoadingMore.value = false
        }
    }

    fun loadPlanets() {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            isRefreshing.value = true
            refreshError.value = null
            val result = repository.refreshPlanets()
            refreshError.value = result.exceptionOrNull()?.message
            isRefreshing.value = false
        }
    }

    fun deleteItem(id: Int) {
        viewModelScope.launch {
            repository.deletePlanet(id)
        }
    }

}

data class PlanetsUiState(
    val query: String = "",
    val totalResults: Int = 0,
    val planets: List<Planet> = emptyList(),
    val isRefreshing: Boolean = false,
    val isLoadingMore: Boolean = false,
    val canLoadMore: Boolean = false,
    val refreshError: String? = null,
)

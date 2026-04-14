package com.dam.starwarsapp.ui.screens.starships

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dam.starwarsapp.domain.model.Starship
import com.dam.starwarsapp.domain.repository.StarshipRepository
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
class StarshipsViewModel @Inject constructor(
    private val repository: StarshipRepository,
) : ViewModel() {

    private val pageSize = 15

    private val query = MutableStateFlow("")
    private val visibleCount = MutableStateFlow(pageSize)

    private val isRefreshing = MutableStateFlow(false)
    private val isLoadingMore = MutableStateFlow(false)
    private val refreshError = MutableStateFlow<String?>(null)

    private val starships: StateFlow<List<Starship>> = repository.observeStarships()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    private val loadingState = combine(
        isRefreshing,
        isLoadingMore,
        refreshError,
    ) { refreshing, loadingMore, error ->
        Triple(refreshing, loadingMore, error)
    }

    val uiState: StateFlow<StarshipsUiState> = combine(
        starships,
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

        StarshipsUiState(
            query = q,
            totalResults = filtered.size,
            starships = items,
            isRefreshing = refreshing,
            isLoadingMore = loadingMore,
            canLoadMore = safeVisible < filtered.size,
            refreshError = error,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), StarshipsUiState())

    init {
        refresh()
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

    fun refresh() {
        viewModelScope.launch {
            isRefreshing.value = true
            refreshError.value = null
            val result = repository.refreshStarships()
            refreshError.value = result.exceptionOrNull()?.message
            isRefreshing.value = false
        }
    }
}

data class StarshipsUiState(
    val query: String = "",
    val totalResults: Int = 0,
    val starships: List<Starship> = emptyList(),
    val isRefreshing: Boolean = false,
    val isLoadingMore: Boolean = false,
    val canLoadMore: Boolean = false,
    val refreshError: String? = null,
)

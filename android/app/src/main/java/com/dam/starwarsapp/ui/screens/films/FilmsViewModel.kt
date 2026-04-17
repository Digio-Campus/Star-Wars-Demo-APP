package com.dam.starwarsapp.ui.screens.films

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dam.starwarsapp.domain.model.Film
import com.dam.starwarsapp.domain.repository.FilmRepository
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
class FilmsViewModel @Inject constructor(
    private val repository: FilmRepository,
) : ViewModel() {

    private val pageSize = 3

    private val query = MutableStateFlow("")
    private val visibleCount = MutableStateFlow(pageSize)

    private val isRefreshing = MutableStateFlow(false)
    private val isLoadingMore = MutableStateFlow(false)
    private val refreshError = MutableStateFlow<String?>(null)

    private val films: StateFlow<List<Film>> = repository.observeFilms()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    private val loadingState = combine(
        isRefreshing,
        isLoadingMore,
        refreshError,
    ) { refreshing, loadingMore, error ->
        Triple(refreshing, loadingMore, error)
    }

    val uiState: StateFlow<FilmsUiState> = combine(
        films,
        query,
        visibleCount,
        loadingState,
    ) { all, q, visible, loading ->
        val (refreshing, loadingMore, error) = loading

        val normalizedQuery = q.trim()
        val filtered = if (normalizedQuery.isBlank()) all else all.filter {
            it.title.contains(normalizedQuery, ignoreCase = true)
        }

        val safeVisible = visible.coerceAtLeast(pageSize).coerceAtMost(filtered.size)
        val items = filtered.take(safeVisible)

        FilmsUiState(
            query = q,
            totalResults = filtered.size,
            films = items,
            isRefreshing = refreshing,
            isLoadingMore = loadingMore,
            canLoadMore = safeVisible < filtered.size,
            refreshError = error,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), FilmsUiState())

    init {
        loadFilms()
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

    fun loadFilms() {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            isRefreshing.value = true
            refreshError.value = null
            val result = repository.refreshFilms()
            refreshError.value = result.exceptionOrNull()?.message
            isRefreshing.value = false
        }
    }

    fun deleteItem(id: Int) {
        viewModelScope.launch {
            repository.deleteFilm(id)
        }
    }

}

data class FilmsUiState(
    val query: String = "",
    val totalResults: Int = 0,
    val films: List<Film> = emptyList(),
    val isRefreshing: Boolean = false,
    val isLoadingMore: Boolean = false,
    val canLoadMore: Boolean = false,
    val refreshError: String? = null,
)

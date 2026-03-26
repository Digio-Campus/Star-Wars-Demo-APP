package com.dam.starwarsapp.ui.screens.films

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dam.starwarsapp.domain.model.Film
import com.dam.starwarsapp.domain.repository.FilmRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject
import kotlin.math.ceil
import kotlin.math.max

@HiltViewModel
class FilmsViewModel @Inject constructor(
    private val repository: FilmRepository,
) : ViewModel() {

    private val pageSize = 3

    private val query = MutableStateFlow("")
    private val page = MutableStateFlow(0)

    private val isRefreshing = MutableStateFlow(false)
    private val refreshError = MutableStateFlow<String?>(null)

    private val films: StateFlow<List<Film>> = repository.observeFilms()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    val uiState: StateFlow<FilmsUiState> = combine(
        films,
        query,
        page,
        isRefreshing,
        refreshError,
    ) { allFilms, q, p, refreshing, error ->
        val normalizedQuery = q.trim()
        val filtered = if (normalizedQuery.isBlank()) {
            allFilms
        } else {
            allFilms.filter { it.title.contains(normalizedQuery, ignoreCase = true) }
        }

        val totalPages = max(1, ceil(filtered.size / pageSize.toDouble()).toInt())
        val safePage = p.coerceIn(0, totalPages - 1)
        val pageItems = filtered.drop(safePage * pageSize).take(pageSize)

        FilmsUiState(
            query = q,
            page = safePage,
            totalPages = totalPages,
            films = pageItems,
            totalResults = filtered.size,
            isRefreshing = refreshing,
            refreshError = error,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), FilmsUiState())

    init {
        refresh()
    }

    fun onQueryChange(newQuery: String) {
        query.value = newQuery
        page.value = 0
    }

    fun nextPage() {
        page.value = page.value + 1
    }

    fun prevPage() {
        page.value = page.value - 1
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
}

data class FilmsUiState(
    val query: String = "",
    val page: Int = 0,
    val totalPages: Int = 1,
    val totalResults: Int = 0,
    val films: List<Film> = emptyList(),
    val isRefreshing: Boolean = false,
    val refreshError: String? = null,
)

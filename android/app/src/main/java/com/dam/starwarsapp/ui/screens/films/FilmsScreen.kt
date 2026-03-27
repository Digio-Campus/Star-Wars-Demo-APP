package com.dam.starwarsapp.ui.screens.films

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilmsScreen(
    viewModel: FilmsViewModel,
    onFilmClick: (Int) -> Unit,
) {
    val state by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Star Wars Films") },
                actions = {
                    IconButton(onClick = viewModel::refresh) {
                        Icon(imageVector = Icons.Default.Refresh, contentDescription = "Refresh")
                    }
                },
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            OutlinedTextField(
                value = state.query,
                onValueChange = viewModel::onQueryChange,
                modifier = Modifier.fillMaxWidth(),
                label = { Text("Search") },
                singleLine = true,
            )

            if (state.refreshError != null) {
                Text(
                    text = "Error updating: ${state.refreshError}",
                    color = MaterialTheme.colorScheme.error,
                )
            }

            if (state.isRefreshing && state.totalResults == 0) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center,
                ) {
                    CircularProgressIndicator()
                }
            }

            Text(
                text = "Results: ${state.totalResults} • Page ${state.page + 1}/${state.totalPages}",
                style = MaterialTheme.typography.labelLarge,
            )

            LazyColumn(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                items(state.films) { film ->
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onFilmClick(film.id) },
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text(
                                text = film.title,
                                style = MaterialTheme.typography.titleLarge,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                            )
                            Spacer(Modifier.padding(2.dp))
                            Text(
                                text = "Episode ${film.episodeId} • ${film.releaseDate}",
                                style = MaterialTheme.typography.bodyMedium,
                            )
                            Text(
                                text = "Director: ${film.director}",
                                style = MaterialTheme.typography.bodySmall,
                            )
                        }
                    }
                }
            }

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Button(
                    onClick = viewModel::prevPage,
                    enabled = state.page > 0,
                ) {
                    Text("Prev")
                }

                if (state.isRefreshing) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        CircularProgressIndicator(modifier = Modifier.padding(end = 8.dp))
                        Text("Updating…")
                    }
                }

                Button(
                    onClick = viewModel::nextPage,
                    enabled = state.page < state.totalPages - 1,
                ) {
                    Text("Next")
                }
            }
        }
    }
}

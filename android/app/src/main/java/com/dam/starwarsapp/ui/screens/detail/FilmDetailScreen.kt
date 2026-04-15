package com.dam.starwarsapp.ui.screens.detail

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun FilmDetailScreen(
    viewModel: FilmDetailViewModel,
    onBack: () -> Unit,
) {
    val state by viewModel.uiState.collectAsState()
    val film = state.film

    ImmersiveDetailScaffold(
        title = film?.title ?: "Película",
        subtitle = film?.let { "Episodio ${it.episodeId} • ${it.releaseDate.asDisplayValue()}" },
        gradient = DetailGradients.film(),
        onBack = onBack,
    ) { isWide ->
        if (film == null) {
            DetailErrorCard(message = "No disponible en caché. Vuelve y actualiza.")
            return@ImmersiveDetailScaffold
        }

        val stats = listOf(
            StatItem("Personajes", film.characterCount.asDisplayValue()),
            StatItem("Planetas", film.planetCount.asDisplayValue()),
            StatItem("Naves", film.starshipCount.asDisplayValue()),
            StatItem("Vehículos", film.vehicleCount.asDisplayValue()),
            StatItem("Especies", film.speciesCount.asDisplayValue()),
        )

        val ficha = listOf(
            DetailField("Episodio", film.episodeId.toString()),
            DetailField("Estreno", film.releaseDate.asDisplayValue()),
            DetailField("Director", film.director.asDisplayValue()),
            DetailField("Productor", film.producer.asDisplayValue()),
        )

        val meta = listOf(
            DetailField("Creado", film.created.asDisplayValue()),
            DetailField("Editado", film.edited.asDisplayValue()),
            DetailField("URL", film.url.asDisplayValue()),
        )

        if (isWide) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    DetailSectionCard(title = "Estadísticas") {
                        DetailStatsGrid(stats = stats, columns = 3)
                    }
                    DetailSectionCard(title = "Ficha") {
                        DetailFieldsList(fields = ficha)
                    }
                }

                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    DetailSectionCard(title = "Crawl") {
                        Text(
                            text = film.openingCrawl.asDisplayValue(),
                            modifier = Modifier.fillMaxWidth(),
                            style = MaterialTheme.typography.bodyMedium,
                        )
                    }
                    DetailSectionCard(title = "Metadatos") {
                        DetailFieldsList(fields = meta)
                    }
                }
            }
        } else {
            DetailSectionCard(title = "Estadísticas") {
                DetailStatsGrid(stats = stats, columns = 2)
            }
            DetailSectionCard(title = "Ficha") {
                DetailFieldsList(fields = ficha)
            }
            DetailSectionCard(title = "Crawl") {
                Text(
                    text = film.openingCrawl.asDisplayValue(),
                    modifier = Modifier.fillMaxWidth(),
                    style = MaterialTheme.typography.bodyMedium,
                )
            }
            DetailSectionCard(title = "Metadatos") {
                DetailFieldsList(fields = meta)
            }
        }
    }
}

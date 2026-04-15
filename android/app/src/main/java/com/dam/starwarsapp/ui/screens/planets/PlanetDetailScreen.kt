package com.dam.starwarsapp.ui.screens.planets

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.dam.starwarsapp.ui.screens.detail.DetailErrorCard
import com.dam.starwarsapp.ui.screens.detail.DetailField
import com.dam.starwarsapp.ui.screens.detail.DetailFieldsList
import com.dam.starwarsapp.ui.screens.detail.DetailGradients
import com.dam.starwarsapp.ui.screens.detail.DetailSectionCard
import com.dam.starwarsapp.ui.screens.detail.DetailStatsGrid
import com.dam.starwarsapp.ui.screens.detail.ImmersiveDetailScaffold
import com.dam.starwarsapp.ui.screens.detail.StatItem
import com.dam.starwarsapp.ui.screens.detail.asDisplayValue

@Composable
fun PlanetDetailScreen(
    viewModel: PlanetDetailViewModel,
    onBack: () -> Unit,
) {
    val state by viewModel.uiState.collectAsState()
    val planet = state.planet

    ImmersiveDetailScaffold(
        title = planet?.name ?: "Planeta",
        subtitle = planet?.let { "Clima ${it.climate.asDisplayValue()}" },
        gradient = DetailGradients.planet(),
        onBack = onBack,
    ) { isWide ->
        if (planet == null) {
            DetailErrorCard(message = "No disponible en caché. Vuelve y actualiza.")
            return@ImmersiveDetailScaffold
        }

        val panel = listOf(
            StatItem("Población", planet.population.asDisplayValue()),
            StatItem("Diámetro", planet.diameter.asDisplayValue()),
            StatItem("Residentes", planet.residentsCount.toString()),
            StatItem("Gravedad", planet.gravity.asDisplayValue()),
        )

        val fields = listOf(
            DetailField("Clima", planet.climate.asDisplayValue()),
            DetailField("Terreno", planet.terrain.asDisplayValue()),
            DetailField("Gravedad", planet.gravity.asDisplayValue()),
            DetailField("Diámetro", planet.diameter.asDisplayValue()),
            DetailField("Población", planet.population.asDisplayValue()),
            DetailField("Residentes", planet.residentsCount.toString()),
            DetailField("Rotación", planet.rotationPeriod.asDisplayValue()),
            DetailField("Órbita", planet.orbitalPeriod.asDisplayValue()),
            DetailField("Agua en superficie", planet.surfaceWater.asDisplayValue()),
        )

        val meta = listOf(
            DetailField("Creado", planet.created.asDisplayValue()),
            DetailField("Editado", planet.edited.asDisplayValue()),
            DetailField("URL", planet.url.asDisplayValue()),
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
                    DetailSectionCard(title = "Panel") {
                        DetailStatsGrid(stats = panel, columns = 2)
                    }
                    DetailSectionCard(title = "Ficha") {
                        DetailFieldsList(fields = fields)
                    }
                }

                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    DetailSectionCard(title = "Metadatos") {
                        DetailFieldsList(fields = meta)
                    }
                }
            }
        } else {
            DetailSectionCard(title = "Panel") {
                DetailStatsGrid(stats = panel, columns = 2)
            }
            DetailSectionCard(title = "Ficha") {
                DetailFieldsList(fields = fields)
            }
            DetailSectionCard(title = "Metadatos") {
                DetailFieldsList(fields = meta)
            }
        }
    }
}

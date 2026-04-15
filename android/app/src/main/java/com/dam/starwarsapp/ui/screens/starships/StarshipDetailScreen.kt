package com.dam.starwarsapp.ui.screens.starships

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
fun StarshipDetailScreen(
    viewModel: StarshipDetailViewModel,
    onBack: () -> Unit,
) {
    val state by viewModel.uiState.collectAsState()
    val starship = state.starship

    ImmersiveDetailScaffold(
        title = starship?.name ?: "Nave",
        subtitle = starship?.model?.let { "Modelo ${it.asDisplayValue()}" },
        gradient = DetailGradients.starship(),
        onBack = onBack,
    ) { isWide ->
        if (starship == null) {
            DetailErrorCard(message = "No disponible en caché. Vuelve y actualiza.")
            return@ImmersiveDetailScaffold
        }

        val panel = listOf(
            StatItem("Tripulación", starship.crew.asDisplayValue()),
            StatItem("Pasajeros", starship.passengers.asDisplayValue()),
            StatItem("Longitud", starship.length.asDisplayValue()),
            StatItem("Coste", starship.costInCredits.asDisplayValue()),
            StatItem("Hiperimpulsor", starship.hyperdriveRating.asDisplayValue()),
        )

        val fields = listOf(
            DetailField("Modelo", starship.model.asDisplayValue()),
            DetailField("Clase", starship.starshipClass.asDisplayValue()),
            DetailField("Fabricante", starship.manufacturer.asDisplayValue()),
            DetailField("Coste", starship.costInCredits.asDisplayValue()),
            DetailField("Tripulación", starship.crew.asDisplayValue()),
            DetailField("Pasajeros", starship.passengers.asDisplayValue()),
            DetailField("Hiperimpulsor", starship.hyperdriveRating.asDisplayValue()),
            DetailField("Longitud", starship.length.asDisplayValue()),
        )

        val meta = listOf(
            DetailField("Creado", starship.created.asDisplayValue()),
            DetailField("Editado", starship.edited.asDisplayValue()),
            DetailField("URL", starship.url.asDisplayValue()),
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
                        DetailStatsGrid(stats = panel, columns = 3)
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

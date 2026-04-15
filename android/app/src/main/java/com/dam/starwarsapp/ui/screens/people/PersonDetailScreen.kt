package com.dam.starwarsapp.ui.screens.people

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
fun PersonDetailScreen(
    viewModel: PersonDetailViewModel,
    onBack: () -> Unit,
) {
    val state by viewModel.uiState.collectAsState()
    val person = state.person

    ImmersiveDetailScaffold(
        title = person?.name ?: "Personaje",
        subtitle = person?.gender?.let { "Género ${it.asDisplayValue()}" },
        gradient = DetailGradients.person(),
        onBack = onBack,
    ) { isWide ->
        if (person == null) {
            DetailErrorCard(message = "No disponible en caché. Vuelve y actualiza.")
            return@ImmersiveDetailScaffold
        }

        val panel = listOf(
            StatItem("Nacimiento", person.birthYear.asDisplayValue()),
            StatItem("Altura", person.height.asDisplayValue()),
            StatItem("Masa", person.mass.asDisplayValue()),
            StatItem("Género", person.gender.asDisplayValue()),
        )

        val fields = listOf(
            DetailField("Nacimiento", person.birthYear.asDisplayValue()),
            DetailField("Altura", person.height.asDisplayValue()),
            DetailField("Masa", person.mass.asDisplayValue()),
            DetailField("Género", person.gender.asDisplayValue()),
            DetailField("Pelo", person.hairColor.asDisplayValue()),
        )

        val extra = listOf(
            DetailField("Piel", person.skinColor.asDisplayValue()),
            DetailField("Ojos", person.eyeColor.asDisplayValue()),
        )

        val meta = listOf(
            DetailField("Creado", person.created.asDisplayValue()),
            DetailField("Editado", person.edited.asDisplayValue()),
            DetailField("URL", person.url.asDisplayValue()),
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
                    DetailSectionCard(title = "Apariencia") {
                        DetailFieldsList(fields = extra)
                    }
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
            DetailSectionCard(title = "Apariencia") {
                DetailFieldsList(fields = extra)
            }
            DetailSectionCard(title = "Metadatos") {
                DetailFieldsList(fields = meta)
            }
        }
    }
}

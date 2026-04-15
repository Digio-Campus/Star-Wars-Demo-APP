package com.dam.starwarsapp.ui.screens.detail

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp

@Immutable
data class DetailField(
    val label: String,
    val value: String,
)

@Immutable
data class StatItem(
    val label: String,
    val value: String,
)

@Composable
fun DetailErrorCard(
    message: String,
    modifier: Modifier = Modifier,
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.errorContainer),
    ) {
        Text(
            text = message,
            modifier = Modifier.padding(16.dp),
            color = MaterialTheme.colorScheme.onErrorContainer,
            style = MaterialTheme.typography.bodyMedium,
        )
    }
}

@Composable
fun DetailSectionCard(
    title: String,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            content()
        }
    }
}

@Composable
fun DetailFieldsList(
    fields: List<DetailField>,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier.fillMaxWidth()) {
        fields.forEachIndexed { index, field ->
            DetailFieldRow(label = field.label, value = field.value)
            if (index != fields.lastIndex) {
                HorizontalDivider(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 10.dp),
                    color = MaterialTheme.colorScheme.outline.copy(alpha = 0.25f),
                )
            }
        }
    }
}

@Composable
fun DetailFieldRow(
    label: String,
    value: String,
    modifier: Modifier = Modifier,
) {
    BoxWithConstraints(modifier = modifier.fillMaxWidth()) {
        val labelWidth = (maxWidth * 0.38f)
            .coerceAtLeast(96.dp)
            .coerceAtMost(180.dp)

        Row(modifier = Modifier.fillMaxWidth()) {
            Text(
                text = label,
                modifier = Modifier.width(labelWidth),
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.9f),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Spacer(modifier = Modifier.width(12.dp))
            Text(
                text = value.ifBlank { "—" },
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                softWrap = true,
            )
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun DetailStatsGrid(
    stats: List<StatItem>,
    columns: Int,
    modifier: Modifier = Modifier,
) {
    val clampedColumns = columns.coerceIn(1, 4)
    val spacing = 10.dp

    BoxWithConstraints(modifier = modifier.fillMaxWidth()) {
        val cardWidth = (maxWidth - (spacing * (clampedColumns - 1))) / clampedColumns

        FlowRow(
            modifier = Modifier.fillMaxWidth(),
            maxItemsInEachRow = clampedColumns,
            horizontalArrangement = Arrangement.spacedBy(spacing),
            verticalArrangement = Arrangement.spacedBy(spacing),
        ) {
            stats.forEach { stat ->
                Card(
                    modifier = Modifier.width(cardWidth),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                ) {
                    Column(modifier = Modifier.padding(12.dp)) {
                        Text(
                            text = stat.label,
                            style = MaterialTheme.typography.labelMedium,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                        Text(
                            text = stat.value.ifBlank { "—" },
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onSurface,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                }
            }
        }
    }
}

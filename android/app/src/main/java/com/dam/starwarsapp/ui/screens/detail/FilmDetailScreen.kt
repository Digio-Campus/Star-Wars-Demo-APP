package com.dam.starwarsapp.ui.screens.detail

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.FrameLayout
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.lifecycleScope
import coil.compose.AsyncImage
import com.dam.starwarsapp.domain.video.PlaybackTarget
import kotlinx.coroutines.launch

@Composable
fun YouTubeThumbnailPlayer(
    videoId: String,
    thumbnailUrl: String?,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    
    Box(
        modifier = modifier
            .fillMaxWidth()
            .clip(MaterialTheme.shapes.medium)
            .background(Color.Black)
            .clickable {
                openYouTubeApp(context, videoId)
            },
        contentAlignment = Alignment.Center
    ) {
        // Thumbnail
        AsyncImage(
            model = thumbnailUrl ?: "https://img.youtube.com/vi/$videoId/hqdefault.jpg",
            contentDescription = "YouTube Thumbnail",
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop,
            alpha = 0.7f
        )
        
        // Gradient overlay for premium feel
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color.Transparent,
                            Color.Black.copy(alpha = 0.4f)
                        )
                    )
                )
        )

        // Play Button Overlay
        Box(
            modifier = Modifier
                .size(64.dp)
                .background(
                    color = Color.Black.copy(alpha = 0.6f),
                    shape = androidx.compose.foundation.shape.CircleShape
                )
                .padding(4.dp),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Filled.PlayArrow,
                contentDescription = "Reproducir",
                tint = Color.White,
                modifier = Modifier.size(40.dp)
            )
        }
        
        // Small YouTube tag
        Text(
            text = "Reproducir en YouTube",
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 12.dp),
            style = MaterialTheme.typography.labelSmall,
            color = Color.White.copy(alpha = 0.8f)
        )
    }
}

@Composable
fun FilmDetailScreen(
    viewModel: FilmDetailViewModel,
    onBack: () -> Unit,
) {
    val state by viewModel.uiState.collectAsState()
    val film = state.film
    val playbackTarget by viewModel.playbackTarget.collectAsState()
    val isVideoLoading by viewModel.isVideoLoading.collectAsState()
    val videoErrorMessage by viewModel.videoErrorMessage.collectAsState()

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

        val crawlText = film.openingCrawl
            .asDisplayValue()
            .replace("\r\n", "\n")
            .trim()
            .split(Regex("\n\\s*\n"))
            .joinToString("\n\n") { paragraph ->
                paragraph
                    .replace("\n", " ")
                    .replace(Regex("\\s+"), " ")
                    .trim()
            }

        if (isWide) {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                DetailSectionCard(
                    title = "Crawl",
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text(
                        text = crawlText,
                        modifier = Modifier.fillMaxWidth(),
                        style = MaterialTheme.typography.bodyMedium,
                        softWrap = true,
                    )
                }

                DetailSectionCard(
                    title = "Video",
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    val context = LocalContext.current
                    when (val target = playbackTarget) {
                        is PlaybackTarget.Embedded -> {
                            when (target.provider.lowercase()) {
                                "youtube" -> {
                                    YouTubeThumbnailPlayer(
                                        videoId = target.videoId,
                                        thumbnailUrl = target.thumbnailUrl,
                                        modifier = Modifier.height(210.dp)
                                    )
                                }
                                else -> {
                                    OutlinedButton(onClick = {
                                        context.startActivity(
                                            Intent(
                                                Intent.ACTION_VIEW,
                                                Uri.parse(target.videoId), // Fallback for other providers
                                            ),
                                        )
                                    }) {
                                        Text("Abrir video")
                                    }
                                }
                            }
                        }
                        is PlaybackTarget.DirectStream -> {
                            DirectStreamPlayerWithCast(url = target.url)
                        }
                        is PlaybackTarget.External -> {
                            OutlinedButton(onClick = {
                                context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(target.url)))
                            }) {
                                Text("Abrir video")
                            }
                        }
                        null -> {
                            if (isVideoLoading) {
                                CircularProgressIndicator()
                            } else {
                                val msg = videoErrorMessage
                                if (!msg.isNullOrBlank()) {
                                    Text(
                                        text = msg,
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                        modifier = Modifier.padding(top = 8.dp),
                                    )
                                } else {
                                    Text(
                                        text = "Vídeo no disponible para esta película.",
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                        modifier = Modifier.padding(top = 8.dp),
                                    )
                                }
                            }
                        }
                    }
                }

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
                        DetailSectionCard(title = "Metadatos") {
                            DetailFieldsList(fields = meta)
                        }
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
            DetailSectionCard(
                title = "Crawl",
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(
                    text = crawlText,
                    modifier = Modifier.fillMaxWidth(),
                    style = MaterialTheme.typography.bodyMedium,
                    softWrap = true,
                )
            }

            DetailSectionCard(title = "Video") {
                val context = LocalContext.current
                when (val target = playbackTarget) {
                    is PlaybackTarget.Embedded -> {
                        when (target.provider.lowercase()) {
                            "youtube" -> {
                                YouTubeThumbnailPlayer(
                                    videoId = target.videoId,
                                    thumbnailUrl = target.thumbnailUrl,
                                    modifier = Modifier.height(210.dp)
                                )
                            }
                            else -> {
                                OutlinedButton(onClick = {
                                    context.startActivity(
                                        Intent(
                                            Intent.ACTION_VIEW,
                                            Uri.parse(target.videoId),
                                        ),
                                    )
                                }) {
                                    Text("Abrir video")
                                }
                            }
                        }
                    }
                    is PlaybackTarget.DirectStream -> {
                        DirectStreamPlayerWithCast(url = target.url)
                    }
                    is PlaybackTarget.External -> {
                        OutlinedButton(onClick = {
                            context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(target.url)))
                        }) {
                            Text("Abrir video")
                        }
                    }
                    null -> {
                        if (isVideoLoading) {
                            CircularProgressIndicator()
                        } else {
                            val msg = videoErrorMessage
                            if (!msg.isNullOrBlank()) {
                                Text(
                                    text = msg,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    modifier = Modifier.padding(top = 8.dp),
                                )
                            } else {
                                Text(
                                    text = "Vídeo no disponible para esta película.",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    modifier = Modifier.padding(top = 8.dp),
                                )
                            }
                        }
                    }
                }
            }

            DetailSectionCard(title = "Metadatos") {
                DetailFieldsList(fields = meta)
            }
        }
    }
}

private fun openYouTubeApp(context: android.content.Context, videoId: String) {
    val appIntent = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:$videoId"))
    val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=$videoId"))

    try {
        context.startActivity(appIntent)
    } catch (_: ActivityNotFoundException) {
        context.startActivity(webIntent)
    }
}

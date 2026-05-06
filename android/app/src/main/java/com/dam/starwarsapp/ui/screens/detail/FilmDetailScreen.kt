package com.dam.starwarsapp.ui.screens.detail

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.lifecycleScope
import android.view.View
import android.widget.FrameLayout
import androidx.compose.foundation.layout.height
import kotlinx.coroutines.launch
import com.dam.starwarsapp.domain.video.PlaybackTarget
import androidx.compose.ui.unit.dp

@Composable
fun AndroidTrailerPlayerComposableForYouTube(videoId: String, modifier: Modifier = Modifier) {
    val lifecycleOwner = LocalLifecycleOwner.current
    AndroidView(
        modifier = modifier,
        factory = { ctx ->
            FrameLayout(ctx).apply {
                val player = com.dam.starwarsapp.data.player.AndroidTrailerPlayer(ctx, lifecycleOwner.lifecycle, this)
                setTag(player)
                lifecycleOwner.lifecycleScope.launch {
                    player.load(com.dam.starwarsapp.domain.video.VideoSource.YouTube(videoId))
                }
                addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
                    override fun onViewAttachedToWindow(v: View) {}
                    override fun onViewDetachedFromWindow(v: View) {
                        (v.getTag() as? com.dam.starwarsapp.domain.video.TrailerPlayer)?.release()
                    }
                })
            }
        }
    )
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
                                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                        AndroidTrailerPlayerComposableForYouTube(
                                            videoId = target.videoId,
                                            modifier = Modifier.height(210.dp),
                                        )

                                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                            OutlinedButton(onClick = {
                                                context.startActivity(
                                                    Intent(
                                                        Intent.ACTION_VIEW,
                                                        Uri.parse("https://youtu.be/${target.videoId}"),
                                                    ),
                                                )
                                            }) {
                                                Text("Abrir en YouTube")
                                            }

                                            OutlinedButton(onClick = {
                                                openYouTubeApp(context, target.videoId)
                                            }) {
                                                Text("Cast")
                                            }
                                        }
                                    }
                                }
                                else -> {
                                    OutlinedButton(onClick = {
                                        context.startActivity(
                                            Intent(
                                                Intent.ACTION_VIEW,
                                                Uri.parse("https://youtu.be/${target.videoId}"),
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
                                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                    AndroidTrailerPlayerComposableForYouTube(
                                        videoId = target.videoId,
                                        modifier = Modifier.height(210.dp),
                                    )

                                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                        OutlinedButton(onClick = {
                                            context.startActivity(
                                                Intent(
                                                    Intent.ACTION_VIEW,
                                                    Uri.parse("https://youtu.be/${target.videoId}"),
                                                ),
                                            )
                                        }) {
                                            Text("Abrir en YouTube")
                                        }

                                        OutlinedButton(onClick = {
                                            openYouTubeApp(context, target.videoId)
                                        }) {
                                            Text("Cast")
                                        }
                                    }
                                }
                            }
                            else -> {
                                OutlinedButton(onClick = {
                                    context.startActivity(
                                        Intent(
                                            Intent.ACTION_VIEW,
                                            Uri.parse("https://youtu.be/${target.videoId}"),
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
    val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://youtu.be/$videoId"))

    try {
        context.startActivity(appIntent)
    } catch (_: ActivityNotFoundException) {
        context.startActivity(webIntent)
    }
}

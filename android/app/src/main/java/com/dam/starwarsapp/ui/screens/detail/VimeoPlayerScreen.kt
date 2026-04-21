package com.dam.starwarsapp.ui.screens.detail

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.media3.common.MediaItem
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.PlayerView
import com.dam.starwarsapp.domain.model.VimeoVideo

@androidx.annotation.OptIn(UnstableApi::class)
@Composable
fun VimeoPlayerScreen(
    vimeoVideo: VimeoVideo?,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val playbackUrl = vimeoVideo?.playbackUrl

    if (playbackUrl.isNullOrBlank()) {
        Box(
            modifier = modifier
                .fillMaxWidth()
                .padding(12.dp),
        ) {
            Text(
                text = "Vídeo no disponible para esta película.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
        return
    }

    val exoPlayer = remember(playbackUrl) {
        runCatching {
            ExoPlayer.Builder(context).build().apply {
                setMediaItem(MediaItem.fromUri(playbackUrl))
                prepare()
                playWhenReady = true
            }
        }.getOrNull()
    }

    if (exoPlayer == null) {
        Box(
            modifier = modifier
                .fillMaxWidth()
                .padding(12.dp),
        ) {
            Text(
                text = "No se pudo inicializar el reproductor.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
        return
    }

    DisposableEffect(exoPlayer) {
        onDispose {
            runCatching { exoPlayer.release() }
        }
    }

    AndroidView(
        modifier = modifier
            .fillMaxWidth()
            .aspectRatio(16 / 9f),
        factory = { viewContext ->
            PlayerView(viewContext).apply {
                player = exoPlayer
                useController = true
                resizeMode = AspectRatioFrameLayout.RESIZE_MODE_ZOOM
            }
        },
    )
}

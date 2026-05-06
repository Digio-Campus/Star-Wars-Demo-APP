package com.dam.starwarsapp.ui.screens.detail

import android.view.ViewGroup
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.media3.cast.CastPlayer
import androidx.media3.cast.SessionAvailabilityListener
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView
import androidx.mediarouter.app.MediaRouteButton
import com.google.android.gms.cast.framework.CastButtonFactory
import com.google.android.gms.cast.framework.CastContext

@androidx.annotation.OptIn(UnstableApi::class)
@Composable
fun DirectStreamPlayerWithCast(
    url: String,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current

    val castContext = remember {
        runCatching { CastContext.getSharedInstance(context) }.getOrNull()
    }

    var isCastSessionAvailable by remember { mutableStateOf(false) }

    val exoPlayer = remember(url) {
        ExoPlayer.Builder(context).build().apply {
            setMediaItem(MediaItem.fromUri(url))
            prepare()
            playWhenReady = true
        }
    }

    val castPlayer = remember(castContext) {
        castContext?.let { CastPlayer(it) }
    }

    var activePlayer: Player by remember { mutableStateOf<Player>(exoPlayer) }

    DisposableEffect(castPlayer) {
        if (castPlayer == null) return@DisposableEffect onDispose { }

        val listener = object : SessionAvailabilityListener {
            override fun onCastSessionAvailable() {
                isCastSessionAvailable = true
            }

            override fun onCastSessionUnavailable() {
                isCastSessionAvailable = false
            }
        }
        castPlayer.setSessionAvailabilityListener(listener)

        onDispose {
            castPlayer.setSessionAvailabilityListener(null)
            runCatching { castPlayer.release() }
        }
    }

    DisposableEffect(exoPlayer) {
        onDispose {
            runCatching { exoPlayer.release() }
        }
    }

    LaunchedEffect(url, isCastSessionAvailable) {
        if (isCastSessionAvailable && castPlayer != null) {
            activePlayer = castPlayer
            runCatching { exoPlayer.pause() }

            castPlayer.setMediaItem(MediaItem.fromUri(url), /* resetPosition= */ true)
            castPlayer.prepare()
            castPlayer.play()
        } else {
            activePlayer = exoPlayer
            runCatching { castPlayer?.stop() }

            exoPlayer.setMediaItem(MediaItem.fromUri(url), /* resetPosition= */ true)
            exoPlayer.prepare()
            exoPlayer.playWhenReady = true
        }
    }

    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        if (castContext != null) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                AndroidView(
                    modifier = Modifier.height(40.dp),
                    factory = { viewContext ->
                        MediaRouteButton(viewContext).apply {
                            layoutParams = ViewGroup.LayoutParams(
                                ViewGroup.LayoutParams.WRAP_CONTENT,
                                ViewGroup.LayoutParams.WRAP_CONTENT,
                            )
                            CastButtonFactory.setUpMediaRouteButton(viewContext, this)
                        }
                    },
                )

                Text(
                    text = if (isCastSessionAvailable) "Conectado" else "Chromecast",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }

        AndroidView(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(16 / 9f),
            factory = { viewContext ->
                PlayerView(viewContext).apply {
                    useController = true
                    player = activePlayer
                }
            },
            update = { view ->
                if (view.player !== activePlayer) {
                    view.player = activePlayer
                }
            },
        )
    }
}

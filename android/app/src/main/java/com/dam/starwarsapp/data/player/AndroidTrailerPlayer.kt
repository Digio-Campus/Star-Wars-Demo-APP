package com.dam.starwarsapp.data.player

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import com.dam.starwarsapp.domain.video.TrailerPlayer
import com.dam.starwarsapp.domain.video.VideoSource
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView

/**
 * Simple Android implementation of TrailerPlayer supporting Direct (Media3) and YouTube (WebView iframe).
 * Casting is left as a TODO when Cast libraries are available.
 */
class AndroidTrailerPlayer(
    private val context: Context,
    private val lifecycle: Lifecycle,
    private val container: ViewGroup,
) : TrailerPlayer {

    private var exoPlayer: ExoPlayer? = null
    private var playerView: PlayerView? = null
    private var webView: WebView? = null
    private var lifecycleObserver: DefaultLifecycleObserver? = null

    init {
        lifecycleObserver = object : DefaultLifecycleObserver {
            override fun onPause(owner: LifecycleOwner) {
                pause()
            }

            override fun onDestroy(owner: LifecycleOwner) {
                release()
            }
        }.also { lifecycle.addObserver(it) }
    }

    override suspend fun load(source: VideoSource) {
        when (source) {
            is VideoSource.Direct -> loadDirect(source.url)
            is VideoSource.YouTube -> loadYouTube(source.videoId)
            is VideoSource.Vimeo -> {
                // Vimeo is handled by existing VimeoPlayerScreen composable as a fallback.
            }
        }
    }

    private fun loadDirect(url: String) {
        releaseMedia()
        exoPlayer = ExoPlayer.Builder(context).build()
        playerView = PlayerView(context).apply {
            player = exoPlayer
            layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            useController = true
        }
        container.addView(playerView)
        val mediaItem = MediaItem.fromUri(url)
        exoPlayer?.setMediaItem(mediaItem)
        exoPlayer?.prepare()
    }

    private fun loadYouTube(videoId: String) {
        releaseMedia()
        webView = WebView(context).apply {
            layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
            settings.javaScriptEnabled = true
            webViewClient = WebViewClient()
            addJavascriptInterface(object {
                @JavascriptInterface
                fun postMessage(msg: String) {
                    // optional bridge from JS
                }
            }, "AndroidBridge")

            val html = """
                <html><body style="margin:0;padding:0;height:100%;width:100%;">
                <div id="player"></div>
                <script>
                  var tag = document.createElement('script');
                  tag.src = "https://www.youtube.com/iframe_api";
                  var firstScriptTag = document.getElementsByTagName('script')[0];
                  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
                  var player;
                  function onYouTubeIframeAPIReady() {
                    player = new YT.Player('player', {
                      height: '100%',
                      width: '100%',
                      videoId: '$videoId',
                      playerVars: { 'autoplay': 0, 'controls': 1 },
                      events: {
                        'onReady': function(event) {
                          try { AndroidBridge.postMessage('ready'); } catch(e) {}
                        }
                      }
                    });
                  }
                  function playVideo() { if (player) player.playVideo(); }
                  function pauseVideo() { if (player) player.pauseVideo(); }
                </script>
                </body></html>
            """.trimIndent()

            loadDataWithBaseURL(null, html, "text/html", "utf-8", null)
        }

        container.addView(webView)
    }

    override fun play() {
        try {
            exoPlayer?.play()
        } catch (e: Exception) {
        }
        try {
            webView?.evaluateJavascript("playVideo()", null)
        } catch (e: Exception) {
        }
    }

    override fun pause() {
        try {
            exoPlayer?.pause()
        } catch (e: Exception) {
        }
        try {
            webView?.evaluateJavascript("pauseVideo()", null)
        } catch (e: Exception) {
        }
    }

    override fun release() {
        try { exoPlayer?.release() } catch (e: Exception) {}
        exoPlayer = null

        if (playerView != null) {
            try { (playerView!!.parent as? ViewGroup)?.removeView(playerView) } catch (e: Exception) {}
            playerView = null
        }

        if (webView != null) {
            try { webView?.stopLoading() } catch (e: Exception) {}
            try { (webView!!.parent as? ViewGroup)?.removeView(webView) } catch (e: Exception) {}
            try { webView!!.removeAllViews() } catch (e: Exception) {}
            try { webView!!.clearHistory() } catch (e: Exception) {}
            try { webView!!.destroy() } catch (e: Exception) {}
            webView = null
        }

        lifecycleObserver?.let { lifecycle.removeObserver(it) }
        lifecycleObserver = null
    }

    override fun enableCasting() {
        // TODO: Wire CastPlayer when Cast libraries are added. Safe no-op for now.
    }

    private fun releaseMedia() {
        try { exoPlayer?.pause() } catch (e: Exception) {}
        webView?.let { try { it.stopLoading() } catch (_: Exception) {} }
        if (playerView != null) {
            try { (playerView!!.parent as? ViewGroup)?.removeView(playerView) } catch (_: Exception) {}
            playerView = null
        }
        if (webView != null) {
            try { (webView!!.parent as? ViewGroup)?.removeView(webView) } catch (_: Exception) {}
            try { webView!!.removeAllViews() } catch (_: Exception) {}
            try { webView!!.destroy() } catch (_: Exception) {}
            webView = null
        }
        exoPlayer = null
    }
}

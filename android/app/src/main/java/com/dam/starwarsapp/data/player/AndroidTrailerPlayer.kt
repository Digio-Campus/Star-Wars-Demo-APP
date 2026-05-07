package com.dam.starwarsapp.data.player

import android.content.Context
import android.view.ViewGroup
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView
import com.dam.starwarsapp.domain.video.TrailerPlayer
import com.dam.starwarsapp.domain.video.VideoSource
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

class AndroidTrailerPlayer(
    private val context: Context,
    private val lifecycle: Lifecycle,
    private val container: ViewGroup
) : TrailerPlayer, LifecycleObserver {

    private var exoPlayer: ExoPlayer? = null
    var webView: WebView? = null

    init {
        lifecycle.addObserver(this)
    }

    override suspend fun load(source: VideoSource) {
        release()

        when (source) {
            is VideoSource.Direct -> loadDirect(source.url)
            is VideoSource.YouTube -> loadYouTube(source.videoId)
            is VideoSource.Vimeo -> loadVimeo(source.videoId)
        }
    }

    private suspend fun loadYouTube(videoId: String) = suspendCancellableCoroutine<Unit> { cont ->
        val embedHtml = """
            <!DOCTYPE html>
            <html>
                <head>
                    <meta name="viewport" content="initial-scale=1.0, width=device-width" />
                    <style>body, html { margin: 0; padding: 0; background-color: #000000; height: 100%; width: 100%; overflow: hidden; }</style>
                </head>
                <body>
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
                                playerVars: {
                                    'playsinline': 1,
                                    'modestbranding': 1,
                                    'rel': 0
                                }
                            });
                        }
                    </script>
                </body>
            </html>
        """.trimIndent()

        webView = WebView(context).apply {
            layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
            setLayerType(android.view.View.LAYER_TYPE_SOFTWARE, null)
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.mediaPlaybackRequiresUserGesture = false
            settings.userAgentString = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
            webViewClient = WebViewClient()
            webChromeClient = android.webkit.WebChromeClient()
        }

        container.addView(webView)
        webView?.loadDataWithBaseURL("https://www.youtube.com", embedHtml, "text/html", "utf-8", null)

        cont.invokeOnCancellation {
            runCatching {
                webView?.stopLoading()
                container.removeView(webView)
                webView?.destroy()
                webView = null
            }
        }

        cont.resume(Unit)
    }

    private suspend fun loadVimeo(videoId: String) = suspendCancellableCoroutine<Unit> { cont ->
        val embedHtml = """
            <html>
                <head>
                    <meta name="viewport" content="initial-scale=1.0, width=device-width" />
                    <style>body { margin: 0; padding: 0; background-color: #000000; }</style>
                </head>
                <body>
                    <iframe width="100%" height="100%" 
                            src="https://player.vimeo.com/video/$videoId?autoplay=1" 
                            frameborder="0" 
                            allow="autoplay; fullscreen; picture-in-picture" 
                            allowfullscreen>
                    </iframe>
                </body>
            </html>
        """.trimIndent()

        webView = WebView(context).apply {
            layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.mediaPlaybackRequiresUserGesture = false
            webViewClient = WebViewClient()
            webChromeClient = android.webkit.WebChromeClient()
        }

        container.addView(webView)
        webView?.loadDataWithBaseURL("https://vimeo.com", embedHtml, "text/html", "utf-8", null)

        cont.invokeOnCancellation {
            runCatching {
                webView?.stopLoading()
                container.removeView(webView)
                webView?.destroy()
                webView = null
            }
        }

        cont.resume(Unit)
    }

    private suspend fun loadDirect(url: String) = suspendCancellableCoroutine<Unit> { cont ->
        exoPlayer = ExoPlayer.Builder(context).build().apply {
            setMediaItem(MediaItem.fromUri(url))
            prepare()
            playWhenReady = true
        }
        
        val playerView = PlayerView(context).apply {
            layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
            player = exoPlayer
        }
        
        container.addView(playerView)

        cont.invokeOnCancellation {
            container.removeView(playerView)
            exoPlayer?.release()
            exoPlayer = null
        }
        
        cont.resume(Unit)
    }

    override fun play() {
        exoPlayer?.play()
    }

    override fun pause() {
        exoPlayer?.pause()
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    override fun release() {
        exoPlayer?.release()
        exoPlayer = null

        webView?.apply {
            stopLoading()
            loadUrl("about:blank")
            container.removeView(this)
            destroy()
        }
        webView = null
        
        container.removeAllViews()
    }

    override fun enableCasting() {
        // Casting to be implemented later
    }
}

package com.dam.starwarsapp.ui.screens.detail

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.view.ViewGroup
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.viewinterop.AndroidView

private class WebViewHolder {
    var webView: WebView? = null
    var lastVideoId: String? = null
}

@Composable
fun YouTubeWebPlayer(
    videoId: String,
    modifier: Modifier = Modifier,
) {
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

    val holder = remember { WebViewHolder() }

    DisposableEffect(Unit) {
        onDispose {
            val webView = holder.webView
            holder.webView = null
            holder.lastVideoId = null

            if (webView != null) {
                runCatching { webView.stopLoading() }
                runCatching { webView.loadUrl("about:blank") }
                runCatching { (webView.parent as? ViewGroup)?.removeView(webView) }
                runCatching { webView.destroy() }
            }
        }
    }

    AndroidView(
        modifier = modifier,
        factory = { ctx ->
            WebView(ctx).apply {
                setLayerType(android.view.View.LAYER_TYPE_SOFTWARE, null)
                
                settings.javaScriptEnabled = true
                settings.domStorageEnabled = true
                settings.mediaPlaybackRequiresUserGesture = false
                settings.userAgentString = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
                
                webViewClient = WebViewClient()
                webChromeClient = android.webkit.WebChromeClient()

                holder.webView = this
                holder.lastVideoId = videoId

                loadDataWithBaseURL("https://www.youtube.com", embedHtml, "text/html", "utf-8", null)
            }
        },
        update = { view ->
            if (holder.lastVideoId != videoId) {
                holder.lastVideoId = videoId
                view.loadDataWithBaseURL("https://www.youtube.com", embedHtml, "text/html", "utf-8", null)
            }
        },
    )
}

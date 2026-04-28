package com.dam.starwarsapp.ui.screens.detail

import android.view.ViewGroup
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView
import com.dam.starwarsapp.util.AppLog

private class WebViewHolder {
    var webView: WebView? = null
    var lastVideoId: String? = null
}

@Composable
fun YouTubeWebPlayer(
    videoId: String,
    modifier: Modifier = Modifier,
) {
    val embedHtml =
        "<html><body style=\"margin:0;padding:0;\"><iframe width=\"100%\" height=\"100%\" src=\"https://www.youtube.com/embed/$videoId?rel=0&modestbranding=1&autoplay=1\" frameborder=\"0\" allow=\"autoplay; encrypted-media\" allowfullscreen></iframe></body></html>"

    val holder = remember { WebViewHolder() }

    DisposableEffect(Unit) {
        onDispose {
            val webView = holder.webView
            val lastId = holder.lastVideoId
            holder.webView = null
            holder.lastVideoId = null

            if (webView != null) {
                AppLog.d(TAG, "Disposing WebView@${webView.hashCode()} (lastVideoId=$lastId)")
                runCatching { webView.stopLoading() }
                runCatching { webView.loadUrl("about:blank") }
                runCatching { (webView.parent as? ViewGroup)?.removeView(webView) }
                runCatching { webView.removeAllViews() }
                runCatching { webView.clearHistory() }
                runCatching { webView.destroy() }
            } else {
                AppLog.d(TAG, "Disposing YouTubeWebPlayer (no WebView instance)")
            }
        }
    }

    AndroidView(
        modifier = modifier,
        factory = { ctx ->
            WebView(ctx).apply {
                settings.javaScriptEnabled = true
                webViewClient = WebViewClient()

                holder.webView = this
                holder.lastVideoId = videoId

                AppLog.d(TAG, "Created WebView@${hashCode()} videoId=$videoId")
                loadDataWithBaseURL(null, embedHtml, "text/html", "utf-8", null)
            }
        },
        update = { view ->
            if (holder.lastVideoId != videoId) {
                holder.lastVideoId = videoId
                AppLog.d(TAG, "Updating WebView@${view.hashCode()} videoId=$videoId")
                view.loadDataWithBaseURL(null, embedHtml, "text/html", "utf-8", null)
            }
        },
    )
}

private const val TAG = "YouTubeWebPlayer"

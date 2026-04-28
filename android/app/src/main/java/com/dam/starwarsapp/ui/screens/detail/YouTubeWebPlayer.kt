package com.dam.starwarsapp.ui.screens.detail

import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView

@Composable
fun YouTubeWebPlayer(
    videoId: String,
    modifier: Modifier = Modifier,
) {
    val embedHtml = "<html><body style=\"margin:0;padding:0;\"><iframe width=\"100%\" height=\"100%\" src=\"https://www.youtube.com/embed/$videoId?rel=0&modestbranding=1&autoplay=1\" frameborder=\"0\" allow=\"autoplay; encrypted-media\" allowfullscreen></iframe></body></html>"

    AndroidView(
        modifier = modifier,
        factory = { ctx ->
            WebView(ctx).apply {
                settings.javaScriptEnabled = true
                webViewClient = WebViewClient()
                loadData(embedHtml, "text/html", "utf-8")
            }
        },
        update = { it.loadData(embedHtml, "text/html", "utf-8") }
    )
}

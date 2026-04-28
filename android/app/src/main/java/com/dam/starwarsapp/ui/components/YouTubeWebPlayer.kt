package com.dam.starwarsapp.ui.components

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
    AndroidView(factory = { context ->
        WebView(context).apply {
            settings.javaScriptEnabled = true
            webViewClient = WebViewClient()
            loadUrl("https://www.youtube.com/embed/$videoId")
        }
    }, modifier = modifier)
}

import SwiftUI
import WebKit

struct YouTubeWebPlayerView: UIViewRepresentable {
    let embedURL: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        if #available(iOS 15.0, *) {
            config.allowsPictureInPictureMediaPlayback = true
        }
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let html = """
        <!doctype html>
        <html>
        <head>
          <meta name='viewport' content='initial-scale=1.0' />
          <style>body,html{margin:0;padding:0;background:transparent;height:100%}iframe{position:absolute;top:0;left:0;width:100%;height:100%;border:0;}</style>
        </head>
        <body>
          <iframe src='\(embedURL.absoluteString)' allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture' allowfullscreen></iframe>
        </body>
        </html>
        """
        uiView.loadHTMLString(html, baseURL: nil)
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {
        uiView.stopLoading()
    }
}

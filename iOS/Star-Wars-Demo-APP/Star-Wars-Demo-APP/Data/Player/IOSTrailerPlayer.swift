import Foundation
import UIKit
import AVKit
import WebKit

final class IOSTrailerPlayer: UIViewController, TrailerPlayer, WKNavigationDelegate, WKScriptMessageHandler {

    private var avPlayer: AVPlayer?
    private var avPlayerController: AVPlayerViewController?
    private var webView: WKWebView?
    private var routePicker: AVRoutePickerView?
    private var currentSource: VideoSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    deinit {
        teardown()
    }

    private func teardown() {
        if let controller = avPlayerController {
            controller.player?.pause()
            controller.player?.replaceCurrentItem(with: nil)
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
            avPlayerController = nil
            avPlayer = nil
        }

        if let wv = webView {
            // Stop any ongoing playback/audio.
            postMessage(play: false)
            wv.stopLoading()
            wv.navigationDelegate = nil
            wv.loadHTMLString("", baseURL: nil)
            wv.removeFromSuperview()
            webView = nil
        }

        if let rp = routePicker {
            rp.removeFromSuperview()
            routePicker = nil
        }

        currentSource = nil
    }

    private func postMessage(play: Bool) {
        guard let wv = webView, let source = currentSource else { return }
        if case .YouTube = source {
            let cmd = play ? "playVideo" : "pauseVideo"
            let js = "var iframe = document.getElementById('player'); if (iframe && iframe.contentWindow) { iframe.contentWindow.postMessage(JSON.stringify({ event: 'command', func: '\(cmd)', args: [] }), '*'); }"
            wv.evaluateJavaScript(js, completionHandler: nil)
        } else if case .Vimeo = source {
            let method = play ? "play" : "pause"
            let js = "var iframe = document.getElementById('player'); if (iframe && iframe.contentWindow) { iframe.contentWindow.postMessage({ method: '\(method)' }, '*'); }"
            wv.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    private func htmlForEmbeddedPlayer(embedURL: String) -> String {
                return """
                <!doctype html>
                <html>
                    <head>
                        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
                    </head>
                    <body style="margin:0;background:#000;">
                                                <iframe id="player" width="100%" height="100%" src="\(embedURL)" frameborder="0"
                                                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen playsinline referrerpolicy="no-referrer"></iframe>
                                                <script>
                                                    (function(){
                                                        function notify(s){ try { window.webkit.messageHandlers.player.postMessage(s); } catch(e) { /* ignore */ } }
                                                        var iframe = document.getElementById('player');
                                                        if (!iframe) { notify('error'); return; }
                                                        // Onload indicates the iframe element loaded; not necessarily playable, but a good sign.
                                                        iframe.onload = function(){ notify('ready'); };
                                                        // Also listen to messages forwarded from the player iframe
                                                        window.addEventListener('message', function(ev){ try { notify('message:'+JSON.stringify(ev.data)); } catch(e){} }, false);
                                                        // If nothing reports readiness within 3s, notify timeout so native can fallback.
                                                        setTimeout(function(){ notify('timeout'); }, 3000);
                                                    })();
                                                </script>
                    </body>
                </html>
                """
        }

            @MainActor
            func load(source: VideoSource) {
                DispatchQueue.main.async {
                    self.teardown()
                    self.currentSource = source

                    switch source {
                    case .Direct(let url):
                let player = AVPlayer(url: url)
                let controller = AVPlayerViewController()
                controller.player = player
                controller.showsPlaybackControls = true
                controller.view.frame = self.view.bounds
                controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.addChild(controller)
                self.view.addSubview(controller.view)
                controller.didMove(toParent: self)
                self.avPlayer = player
                self.avPlayerController = controller

            case .YouTube(let videoId, _):
                let config = WKWebViewConfiguration()
                config.allowsInlineMediaPlayback = true
                config.allowsAirPlayForMediaPlayback = true
                if #available(iOS 10.0, *) {
                    config.mediaTypesRequiringUserActionForPlayback = []
                }
                if #available(iOS 14.0, *) {
                    config.defaultWebpagePreferences.allowsContentJavaScript = true
                }
                config.userContentController.add(self, name: "player")
                let wv = WKWebView(frame: self.view.bounds, configuration: config)
                wv.navigationDelegate = self
                wv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                wv.scrollView.isScrollEnabled = false
                self.view.addSubview(wv)
                // Provide a non-null origin to improve compatibility with YouTube embeds.
                let origin = "https://www.youtube.com"
                let embed = "https://www.youtube.com/embed/\(videoId)?playsinline=1&enablejsapi=1&origin=\(origin)"
                wv.loadHTMLString(self.htmlForEmbeddedPlayer(embedURL: embed), baseURL: URL(string: origin))
                self.webView = wv

            case .Vimeo(let videoId):
                let config = WKWebViewConfiguration()
                config.allowsInlineMediaPlayback = true
                config.allowsAirPlayForMediaPlayback = true
                if #available(iOS 10.0, *) {
                    config.mediaTypesRequiringUserActionForPlayback = []
                }
                if #available(iOS 14.0, *) {
                    config.defaultWebpagePreferences.allowsContentJavaScript = true
                }
                config.userContentController.add(self, name: "player")
                let wv = WKWebView(frame: self.view.bounds, configuration: config)
                wv.navigationDelegate = self
                wv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                wv.scrollView.isScrollEnabled = false
                self.view.addSubview(wv)
                let embed = "https://player.vimeo.com/video/\(videoId)?playsinline=1"
                wv.loadHTMLString(self.htmlForEmbeddedPlayer(embedURL: embed), baseURL: URL(string: "https://player.vimeo.com"))
                self.webView = wv
            }
        }
    }

    // WKScriptMessageHandler: receive messages from the injected JS in the embed HTML
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "player" else { return }
        if let body = message.body as? String {
            if body == "ready" {
                return
            }
            if body == "timeout" || body == "error" || body.starts(with: "message:") {
                DispatchQueue.main.async {
                    if let source = self.currentSource {
                        switch source {
                        case .YouTube(let videoId, _):
                            if let url = URL(string: "https://www.youtube.com/watch?v=\(videoId)") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        case .Vimeo(let videoId):
                            if let url = URL(string: "https://vimeo.com/\(videoId)") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }
    }


    func play() {
        DispatchQueue.main.async {
            if let player = self.avPlayer {
                player.play()
            } else {
                self.postMessage(play: true)
            }
        }
    }

    func pause() {
        DispatchQueue.main.async {
            if let player = self.avPlayer {
                player.pause()
            } else {
                self.postMessage(play: false)
            }
        }
    }

    func enableCasting() {
        DispatchQueue.main.async {
            guard self.routePicker == nil else { return }
            let size: CGFloat = 44
            let rp = AVRoutePickerView(
                frame: CGRect(x: self.view.bounds.width - size - 8, y: 8, width: size, height: size)
            )
            rp.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
            rp.backgroundColor = .clear
            if #available(iOS 14.0, *) {
                rp.prioritizesVideoDevices = true
            }
            self.view.addSubview(rp)
            self.routePicker = rp
        }
    }

    func cleanup() {
        DispatchQueue.main.async {
            self.teardown()
        }
    }
}

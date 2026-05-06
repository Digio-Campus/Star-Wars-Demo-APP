import Foundation
import UIKit
import AVKit
import WebKit

final class IOSTrailerPlayer: UIViewController {

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
        """
        <!doctype html>
        <html>
          <body style=\"margin:0;background:#000;\">
            <iframe id=\"player\" width=\"100%\" height=\"100%\" src=\"\(embedURL)\" frameborder=\"0\"
              allow=\"autoplay; encrypted-media; picture-in-picture\" allowfullscreen></iframe>
          </body>
        </html>
        """
    }
}

extension IOSTrailerPlayer: WKNavigationDelegate {}

extension IOSTrailerPlayer: TrailerPlayer {
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

            case .YouTube(let videoId):
                let config = WKWebViewConfiguration()
                config.allowsInlineMediaPlayback = true
                config.allowsAirPlayForMediaPlayback = true
                if #available(iOS 10.0, *) {
                    config.mediaTypesRequiringUserActionForPlayback = []
                }
                if #available(iOS 14.0, *) {
                    config.defaultWebpagePreferences.allowsContentJavaScript = true
                }
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

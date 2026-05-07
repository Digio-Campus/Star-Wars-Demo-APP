import SwiftUI

struct YouTubeThumbnailPlayerView: View {
    let videoId: String
    let thumbnailUrl: URL?
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Button {
            openYouTube(videoId: videoId)
        } label: {
            ZStack {
                // Thumbnail Image
                AsyncImage(url: thumbnailUrl ?? URL(string: "https://img.youtube.com/vi/\(videoId)/hqdefault.jpg")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Color.black
                            .overlay(
                                Image(systemName: "video.slash")
                                    .foregroundColor(.white.opacity(0.5))
                            )
                    case .empty:
                        ProgressView()
                            .tint(.white)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .clipped()
                
                // Subtle dark gradient for depth
                LinearGradient(
                    colors: [.clear, .black.opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Play Icon Overlay
                VStack {
                    ZStack {
                        Circle()
                            .fill(.black.opacity(0.5))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .offset(x: 3) // Align triangle center
                    }
                }
                
                // YouTube Indicator
                VStack {
                    Spacer()
                    Text("Reproducir en YouTube")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(.black.opacity(0.5), in: Capsule())
                        .padding(.bottom, 12)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private func openYouTube(videoId: String) {
        // iOS URL Schemes for YouTube
        let appURL = URL(string: "youtube://\(videoId)")!
        let webURL = URL(string: "https://www.youtube.com/watch?v=\(videoId)")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            UIApplication.shared.open(webURL)
        }
    }
}

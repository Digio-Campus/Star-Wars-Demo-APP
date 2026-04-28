YouTube Video Provider (Android)

Setup

1. Add your YouTube API key to android/local.properties (do NOT commit this file):

   YOUTUBE_API_KEY=YOUR_API_KEY_HERE

2. Build the Android app. The key is injected into BuildConfig as YOUTUBE_API_KEY.

How it works

- Video domain contracts are in: android/app/src/main/java/com/dam/starwarsapp/domain/
- YouTube provider uses YouTube Data API v3 (search.list) to find the first embeddable video.
- Playback for YouTube is done via an embedded WebView: https://www.youtube.com/embed/{videoId}
- A VideoResolver orchestrates YouTube first, then falls back to Vimeo if available.

Testing locally

- To test, open a film detail screen and verify the embedded player appears for titles with YouTube results.
- If embedding fails, the UI provides a fallback to open the video externally.

Notes

- API key must NOT be committed. The repo follows the existing VIMEO token pattern in build.gradle.kts.
- Quota: minimize calls by caching resolved results in memory.

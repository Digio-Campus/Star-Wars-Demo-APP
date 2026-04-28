This folder contains scaffolding for the Video Provider abstraction requested in PLANIFICACION-VIDEO-PROVIDERS.md.

Files added (scaffold):
- domain/video/VideoCandidate.kt
- domain/video/PlaybackTarget.kt
- domain/video/VideoError.kt
- domain/video/VideoProvider.kt
- domain/video/VideoResolver.kt

Next steps:
- Implement YouTubeProvider using Retrofit + OkHttp calling https://www.googleapis.com/youtube/v3/search
- Wire YOUTUBE_API_KEY from android/local.properties into BuildConfig (do not commit keys)
- Add YouTubeWebPlayer Compose component and integrate into FilmDetailScreen
- Add unit tests for parsing and middleware

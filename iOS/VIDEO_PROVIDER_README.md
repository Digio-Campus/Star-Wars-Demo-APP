iOS Video Provider README

Environment
- Add your YouTube API key to iOS/Star-Wars-Demo-APP/Star-Wars-Demo-APP/Config.xcconfig as:
    YOUTUBE_API_KEY = your_api_key_here

Notes
- Do NOT commit your API key. Config.xcconfig should be kept local / unversioned.
- The app reads the key from Info.plist via the xcconfig mapping (Bundle.main.infoDictionary["YOUTUBE_API_KEY"]).

Testing locally
- Run the app in Xcode (iOS target). Ensure the xcconfig is included in the scheme and the key is available in the build settings.
- Film detail screen will attempt to resolve a video (YouTube first, Vimeo fallback).

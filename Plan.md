# 🌌 Plan de Implementación Extenso: Capa de Vídeo Multi-Proveedor y Casting

Este documento detalla a nivel de arquitectura, clases, e integraciones específicas la implementación requerida para incorporar un sistema robusto de video en la aplicación móvil de Star Wars para Android e iOS.

---

## 1. Visión Arquitectónica y Modelos de Dominio

La idea central es desacoplar completamente las vistas (UI) de los proveedores de video (YouTube, Vimeo, etc.). Las vistas solo sabrán reproducir un `PlaybackTarget`.

### 1.1 Contratos y Entidades (Domain Layer)
Se aplicarán estos modelos en ambas plataformas (Kotlin y Swift):

*   **`VideoCandidate`**: Representa el video encontrado por un proveedor antes de decidir cómo se va a reproducir.
    *   `contentId`: String (ID del video).
    *   `provider`: String (`youtube` o `vimeo`).
    *   `title`: String.
    *   `embeddable`: Boolean.
*   **`PlaybackTarget`**: (Sealed class / Enum) Define el formato final a reproducir.
    *   `Embedded(videoId, provider)`: El video requiere ser reproducido dentro de un `WebView` (Ej: IFrame de YouTube).
    *   `DirectStream(url)`: El video proporciona un enlace `.mp4` o `.m3u8` en crudo que será lanzado a un reproductor nativo (`ExoPlayer` / `AVPlayer`).
    *   `External(url)`: El video no se puede embeber y debe abrirse en la app nativa o el navegador (Fallback).
*   **`VideoResolver`**: Orquestador principal de la inyección de dependencias. Contiene una lista de `VideoProvider`. Probará suerte primero con YouTube, y si falla o no es *embeddable*, hará fallback a Vimeo.

---

## 2. Implementación Android (Kotlin & Jetpack Compose)

### 2.1 Dependencias Gradle
Se debe asegurar la inclusión de Media3 (ExoPlayer) y el módulo específico de Cast:
```kotlin
implementation("androidx.media3:media3-exoplayer:1.X.X")
implementation("androidx.media3:media3-ui:1.X.X")
implementation("androidx.media3:media3-cast:1.X.X") // <-- NUEVO PARA CHROMECAST
```

### 2.2 Capa de Datos (Data Layer)
*   **`YouTubeProvider.kt`**: Usará Retrofit (`YouTubeService`) para llamar al endpoint `https://www.googleapis.com/youtube/v3/search`.
    *   Parámetros clave: `q = "$filmTitle trailer official"`, `videoEmbeddable = true`, `type = video`.
    *   Mapeará la respuesta a un `VideoCandidate`.
*   **`VideoResolverImpl.kt`**: Recorrerá iterativamente `providers = listOf(youTubeProvider, vimeoProvider)`. Si uno retorna éxito, devolverá un `PlaybackTarget.Embedded` (para YouTube) o `PlaybackTarget.DirectStream` (para Vimeo).

### 2.3 Reproductor Nativo y Chromecast (`AndroidTrailerPlayer.kt`)
Se refactorizará el gestor del reproductor (`TrailerPlayer` interface):
*   **ExoPlayer**: Instanciado si el target es `DirectStream`. Se vinculará a un `PlayerView`.
*   **WebView**: Instanciado si el target es `Embedded`. Se cargará la YouTube IFrame API usando `loadDataWithBaseURL`.
*   **Soporte de Chromecast**:
    1.  Se creará un `CastOptionsProvider` implementando `OptionsProvider` para inicializar el SDK de Cast en el `AndroidManifest.xml` (`<meta-data android:name="com.google.android.gms.cast.framework.OPTIONS_PROVIDER_CLASS_NAME" .../>`).
    2.  En `AndroidTrailerPlayer`, se instanciará un `CastPlayer(castContext)`.
    3.  La UI mostrará dinámicamente un `MediaRouteButton` desde Jetpack Compose usando `AndroidView` para permitir conectar a dispositivos Google Cast.

### 2.4 Integración UI (`FilmDetailScreen.kt` & `FilmDetailViewModel.kt`)
*   **`FilmDetailViewModel`**:
    *   Llamará a `videoResolver.resolve(film.title)`.
    *   Actualizará un `StateFlow<PlaybackTarget?>`.
*   **`FilmDetailScreen`**:
    *   En la tarjeta "Video", hará un `when(playbackTarget)`.
    *   Si es `Embedded(youtube)`, llamará al composable `AndroidTrailerPlayerComposableForYouTube`.
    *   Si es `DirectStream`, cargará ExoPlayer.

---

## 3. Implementación iOS (Swift & SwiftUI)

### 3.1 Configuración de Proyecto y Secretos
*   La clave de YouTube se inyectará desde `Config.xcconfig` (`YOUTUBE_API_KEY`) y se leerá vía Info.plist usando `Bundle.main.object(forInfoDictionaryKey:)`.

### 3.2 Capa de Datos (Data Layer)
*   **`YouTubeProvider.swift`**: Hará uso de `URLSession` para consumir la API de YouTube Data v3. Realizará dos llamadas si es necesario: una a `search.list` y otra opcional a `videos.list` (para validar restricciones geográficas mediante `contentDetails.regionRestriction`).
*   **`VideoResolverImpl.swift`**: Ejecutará el provider principal y retornará un enum `PlaybackTarget.embedded` o `.vimeo`.

### 3.3 Reproductor Nativo y AirPlay (`IOSTrailerPlayer.swift`)
La clase controladora actual (que implementa la interfaz `TrailerPlayer`) se vitaminará:
*   **AVPlayerViewController**: Para videos que retornan streams directos (`DirectStream` / `Vimeo`). Este controlador provee capacidades nativas.
*   **WKWebView**: Para embebidos de YouTube. Se inicializará con configuración para media:
    ```swift
    let config = WKWebViewConfiguration()
    config.allowsInlineMediaPlayback = true
    config.allowsAirPlayForMediaPlayback = true // <-- CRUCIAL PARA AIRPLAY EN WEBVIEW
    ```
*   **Soporte AirPlay (AVRoutePickerView)**:
    1.  Tanto `AVPlayer` como `WKWebView` (con la config de arriba) soportan AirPlay internamente.
    2.  Sin embargo, se instanciará un `AVRoutePickerView` superpuesto en la interfaz o añadido a la barra de navegación para forzar el icono de AirPlay y hacerlo evidente al usuario.

### 3.4 Integración UI (`FilmDetailView.swift` & `FilmDetailViewModel.swift`)
*   **`FilmDetailViewModel`**:
    *   Cambiará la lógica estricta de `vimeoRepository` por el `videoResolver.resolve(title: film.title)`.
    *   Expondrá `@Published private(set) var playbackTarget: PlaybackTarget?`.
*   **`FilmDetailView`**:
    *   La sección *Video* evaluará si el target es nulo. Si no lo es, insertará `IOSTrailerPlayerView` (que implementa `UIViewControllerRepresentable`).

---

## 4. Gestión de Errores y Casos Límite
1.  **Excesos de Cuota (YouTube API):** Si ocurre un HTTP 403 (Quota Exceeded), el middleware `VideoResolver` cortocircuitará y probará directamente con Vimeo para esa y futuras peticiones de la sesión cacheada.
2.  **Videos Restringidos Geográficamente:** La selección intentará ignorar videos que declaren bloqueos por región en la metadata de YouTube.
3.  **Lifecycle Management:** Se prestará extrema precaución a los WebViews tanto en Compose como en SwiftUI para destruirlos (`destroy()`, `stopLoading()`) correctamente al abandonar el detalle, evitando fugas de memoria o audios que suenan en background.

---

## User Review Required
> [!IMPORTANT]
> **Limitaciones de Chromecast con WebViews (YouTube):**
> En **iOS**, AirPlay funciona casi mágicamente "out-of-the-box" incluso en WebViews si se configuran los flags adecuados.
> En **Android**, `ExoPlayer` tiene soporte nativo perfecto para Chromecast, **pero un WebView cargando un IFrame de YouTube NO transmite fácilmente al Chromecast local** (requeriría APIs JS complejas no fiables). Si un vídeo se resuelve como YouTube, ¿es aceptable que el icono de Chromecast abra la App nativa de YouTube para hacer el cast, o prefieres limitar el Cast en Android exclusivamente a los vídeos que sean `DirectStream` (ExoPlayer)?

## Resumen de Ejecución
1. El subagente 1 tomará la tarea de Android (Kotlin, Jetpack Compose, ExoPlayer, Chromecast API).
2. El subagente 2 tomará la tarea de iOS (Swift, SwiftUI, AVPlayer, AirPlay, WKWebView).
3. Ambos compartirán la misma visión arquitectónica descrita aquí.

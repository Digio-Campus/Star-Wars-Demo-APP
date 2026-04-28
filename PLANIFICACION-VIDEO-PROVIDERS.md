# 🌌 Star Wars Demo APP — Planificación: Capa de Vídeo Multi‑Proveedor (YouTube primero)

> **Fecha:** 2026-04-28  
> **Estado:** Planificación (sin implementar)  
> **Objetivo:** Sustituir Vimeo (bloqueo regional) por YouTube, sin reescribir la app, mediante una capa de abstracción (“middleware”) que permita soportar múltiples proveedores de vídeo.

---

## Tabla de contenidos

1. [Contexto y problema](#1-contexto-y-problema)
2. [Objetivos y no‑objetivos](#2-objetivos-y-noobjetivos)
3. [Decisiones clave (YouTube vs URLs directas)](#3-decisiones-clave-youtube-vs-urls-directas)
4. [Arquitectura propuesta](#4-arquitectura-propuesta)
5. [Contratos de dominio (agnósticos)](#5-contratos-de-dominio-agnósticos)
6. [Middleware de selección (orquestador)](#6-middleware-de-selección-orquestador)
7. [Proveedor YouTube (Data API v3)](#7-proveedor-youtube-data-api-v3)
8. [Players por plataforma](#8-players-por-plataforma)
9. [Integración con pantallas actuales](#9-integración-con-pantallas-actuales)
10. [Config y secretos](#10-config-y-secretos)
11. [Caché, cuotas y observabilidad](#11-caché-cuotas-y-observabilidad)
12. [Plan de implementación (por fases)](#12-plan-de-implementación-por-fases)
13. [Criterios de aceptación](#13-criterios-de-aceptación)
14. [Testing mínimo](#14-testing-mínimo)
15. [Riesgos y mitigaciones](#15-riesgos-y-mitigaciones)

---

## 1) Contexto y problema

- Vimeo devuelve **error_code 5451 (restricción regional)** desde la red/región actual.
- Aunque el token de Vimeo sea válido, el proveedor no es confiable para todos los entornos.
- Necesitamos una solución que:
  - Permita cambiar de proveedor sin tocar UI y lógica de detalle.
  - Soporte **fallbacks** (si un proveedor falla, probar otro).

---

## 2) Objetivos y no‑objetivos

### Objetivos

- Definir una **abstracción de vídeo** independiente del proveedor (YouTube/Vimeo/otros).
- Implementar un **middleware/orquestador** que seleccione proveedor y gestione fallback.
- Implementar un **primer proveedor: YouTube** para:
  - Buscar por título de película.
  - Tomar el primer resultado “usable”.
  - Reproducirlo dentro de la app.

### No‑objetivos (explícitos)

- No intentar “saltarse” restricciones regionales.
- No extraer ni usar URLs de streams directos de YouTube (no es el objetivo del Data API).
- No implementar descarga offline de vídeo.

---

## 3) Decisiones clave (YouTube vs URLs directas)

### Lo que YouTube Data API v3 **sí** ofrece

- Búsqueda: `search.list` con parámetros como `q`, `type=video`, `maxResults`, `videoEmbeddable=true`.
- Metadata del vídeo y **`videoId`**.
- (Opcional) `player.embedHtml` en `videos.list`.

### Lo que YouTube Data API v3 **no** ofrece (para nuestro caso)

- **No** devuelve URLs HLS/MP4 directas para reproducir con `AVPlayer/ExoPlayer`.

### Implicación

- Para YouTube, el target de reproducción será **Embedded** (iFrame / embed) dentro de `WKWebView` (iOS) y `WebView` (Android), o **External** (abrir en navegador) como fallback.
- Para proveedores como Vimeo (si se mantiene), el target puede seguir siendo **DirectStream** (HLS/MP4).

---

## 4) Arquitectura propuesta

### Principio

La UI y los ViewModels solo deben conocer un concepto: **“resolver un vídeo para un título”** y recibir un resultado reproducible o un error estandarizado.

### Capas

- **Domain**
  - Contratos agnósticos: `VideoProvider`, `VideoResolver`, modelos `VideoCandidate` y `PlaybackTarget`.
- **Data**
  - Implementaciones de proveedores: `YouTubeProvider`, `VimeoProvider` (opcional).
  - Clientes HTTP (Retrofit/URLSession) + parsing.
- **UI**
  - Un componente de player por tipo de `PlaybackTarget`.

---

## 5) Contratos de dominio (agnósticos)

### Modelos (conceptuales)

- `VideoCandidate`
  - `provider`: identificador estable del proveedor (`youtube`, `vimeo`, ...)
  - `contentId`: id interno (YouTube `videoId`, Vimeo `videoId`, ...)
  - `title`: título
  - `watchUrl`: URL para abrir en navegador
  - `thumbnailUrl` (opcional)

- `PlaybackTarget` (sealed/enum)
  - `Embedded(url)` → reproduce en WebView
  - `DirectStream(url)` → reproduce en AVPlayer/ExoPlayer
  - `External(url)` → abre navegador

- `VideoError`
  - `kind`: `AuthMissing | Quota | RegionBlocked | NotFound | Network | ProviderUnsupported | Unknown`
  - `message`
  - `rawCode` / `httpStatus` (opcionales)

### Interface del proveedor (pseudocontrato)

**Funciones mínimas**:

1) `searchFirst(title)` → `VideoCandidate?`
2) `resolvePlayback(candidate)` → `PlaybackTarget?` (o error)

Notas:
- Para YouTube `resolvePlayback()` suele ser determinista (construir embed URL) y casi siempre no necesita segunda llamada.
- Para Vimeo `resolvePlayback()` requiere llamada adicional a `fields=play`.

---

## 6) Middleware de selección (orquestador)

### Responsabilidades

- Normalizar query:
  - `trim`, colapsar múltiples espacios, evitar strings vacíos.
- Política de selección:
  - Lista ordenada de proveedores: p.ej. `YouTube → Vimeo → External fallback`.
- Estrategia de fallback:
  - Si un proveedor falla con error recuperable (`NotFound`, `RegionBlocked`, `Network`), intentar el siguiente.
  - Si falla por error fatal (`AuthMissing` o `Quota`), decidir:
    - O cortar (para evitar quemar más cuota),
    - O continuar (si el siguiente proveedor no depende de esa credencial).

### Cache

- Cachear por clave `normalizedTitle`:
  - Resultado exitoso: TTL medio (ej. 7 días)
  - Resultado nulo / error `NotFound`: TTL corto (ej. 24h)
  - Error `Quota`: TTL muy corto (ej. 10–30 min)

---

## 7) Proveedor YouTube (Data API v3)

### Autenticación

- Para búsquedas públicas: **API key** (`key=...`) es suficiente.
- OAuth 2.0 solo si se requieren datos privados (no necesario para este caso).

### Búsqueda (search.list)

Endpoint:

```text
GET https://www.googleapis.com/youtube/v3/search
```

Parámetros recomendados (MVP):

- `part=snippet`
- `q=<film title>`
- `type=video`
- `maxResults=1`
- `videoEmbeddable=true`
- `key=<API_KEY>`

Notas:
- `search.list` tiene coste de cuota (documentado como **100 unidades** por request).

### Construcción de playback

- `Embedded(url)` con:

```text
https://www.youtube.com/embed/{videoId}
```

- `watchUrl` (fallback/external):

```text
https://www.youtube.com/watch?v={videoId}
```

### Casos especiales

- Vídeo no embebible / embed bloqueado:
  - fallback automático a `External(watchUrl)`.

---

## 8) Players por plataforma

### iOS

- `Embedded`: `WKWebView` con iframe embed.
- `DirectStream`: `AVPlayer`.
- `External`: `openURL` (Safari).

Requisitos UX:
- Placeholder + loading.
- Error + botón “Reintentar”.
- Mantener el detalle usable aunque no haya vídeo.

### Android

- `Embedded`: `WebView` (iframe embed).
- `DirectStream`: ExoPlayer (Media3) como ya existe.
- `External`: `Intent.ACTION_VIEW`.

Requisitos Compose:
- Evitar recrear el player en recomposición.
- Mantener estado con `StateFlow`/`collectAsStateWithLifecycle`.

---

## 9) Integración con pantallas actuales

### Situación actual (referencia)

- Android tiene `VimeoRepositoryImpl` que devuelve `VimeoVideo` con `playbackUrl`.
- iOS tiene `VimeoService` y `VimeoRepository`.

### Migración propuesta

- Introducir `VideoResolver` en Domain.
- Reemplazar en los ViewModels del detalle:
  - Antes: `searchVimeoVideo(title)`
  - Después: `resolveVideo(title)` → devuelve `PlaybackTarget` + metadata.

### Compatibilidad

- Vimeo puede quedarse como provider opcional (para entornos donde funcione).
- YouTube como provider principal.

---

## 10) Config y secretos

### Android

- Añadir `YOUTUBE_API_KEY` a `android/local.properties`.
- Inyectarlo en `BuildConfig` (igual que se hace con `VIMEO_ACCESS_TOKEN`).

### iOS

- Añadir `YOUTUBE_API_KEY` a `iOS/Star-Wars-Demo-APP/Config.xcconfig` (local, no versionado).
- Mapearlo a Info.plist con un xcconfig similar a `VimeoConfig.xcconfig`.

### Reglas

- No commitear claves.
- Redactar claves en logs.

---

## 11) Caché, cuotas y observabilidad

### Caché

- En memoria (MVP) y extensible a persistencia si se desea.
- Cache negativa para reducir llamadas repetidas.

### Cuota (YouTube)

- Debe evitarse hacer search por cada recomposición o cada aparición del detalle.
- Resolver 1 vez por película y cachear.

### Observabilidad

- Logs por provider:
  - tiempo total, cache hit/miss, error kind.
- En debug: loggear URLs (sin exponer API key).

---

## 12) Plan de implementación (por fases)

### Fase 0 — Preparación (0.5 día)

- Alinear naming:
  - “Video” en vez de “Vimeo” en contratos nuevos.
- Definir estructura de paquetes/carpetas (Android/iOS) para providers.

### Fase 1 — Abstracción Domain (0.5–1 día)

- Crear contratos `VideoProvider`, `VideoResolver`.
- Crear modelos `VideoCandidate`, `PlaybackTarget`, `VideoError`.

### Fase 2 — Middleware (0.5–1 día)

- Implementar política de selección y fallback.
- Implementar cache + TTL.

### Fase 3 — Proveedor YouTube (1–2 días)

- Implementar `searchFirst()` con `search.list`.
- Construir `Embedded` + `watchUrl`.
- Manejar errores comunes (401/403/quota).

### Fase 4 — Player YouTube (iOS) (1 día)

- Componente `YouTubeWebPlayerView` (WKWebView).
- Integración en pantalla de detalle según `PlaybackTarget`.

### Fase 5 — Player YouTube (Android) (1–2 días)

- Componente `YouTubeWebPlayer` (WebView en Compose/AndroidView).
- Integración en pantalla de detalle según `PlaybackTarget`.

### Fase 6 — Migración y UX fallback (0.5–1 día)

- Actualizar ViewModels para usar `VideoResolver`.
- Mostrar error + botón retry.
- “Abrir en navegador” como fallback si embed falla.

### Fase 7 — Hardening (0.5–1 día)

- Mejoras de cache.
- Throttling.
- Logs consistentes.

---

## 13) Criterios de aceptación

- Dado un título de película, la app:
  - Muestra un vídeo reproducible (YouTube embed) o un estado “No disponible” sin romper el resto de la UI.
- Si el proveedor principal falla, se prueba el siguiente según política.
- No hay secretos en repositorio.
- No hay requests repetidas por recomposición.

---

## 14) Testing mínimo

- Unit tests del middleware:
  - orden de providers
  - fallback
  - cache hit/miss
  - normalización de query

- Tests de parsing (YouTube search):
  - extraer `videoId` correctamente

- Smoke test manual:
  - película con resultados
  - película sin resultados
  - modo avión (error de red)

---

## 15) Riesgos y mitigaciones

- **Cuota YouTube**: `search.list` cuesta 100 unidades → Mitigar con cache + TTL y resolver una vez.
- **Vídeos no embebibles**: usar `videoEmbeddable=true` y fallback `External`.
- **Cambios de políticas**: encapsular provider y mantener `PlaybackTarget` estable.
- **WebView UX**: mantener controles básicos y un fallback a navegador.

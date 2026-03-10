# 🌌 Star Wars Demo APP — Plan de Desarrollo Completo

> **Versión del documento:** 2.0  
> **Fecha:** 2026-03-10  
> **Estado del proyecto:** En desarrollo activo  
> **Plataformas:** Android (activo) · iOS (activo)  
> **Estrategia de desarrollo:** Paralelo con subagentes (un agente por plataforma)

---

## Tabla de Contenidos

1. [Visión General del Proyecto](#1-visión-general-del-proyecto)
2. [Análisis de la API (SWAPI)](#2-análisis-de-la-api-swapi)
3. [Arquitectura General](#3-arquitectura-general)
4. [Diseño de Pantallas y Navegación](#4-diseño-de-pantallas-y-navegación)
5. [Plan Android — Desarrollo Activo](#5-plan-android--desarrollo-activo)
6. [Plan iOS — Desarrollo Activo](#6-plan-ios--desarrollo-activo)
7. [Estrategia de Paginación y Búsqueda](#7-estrategia-de-paginación-y-búsqueda)
8. [Definición de Modelos de Datos](#8-definición-de-modelos-de-datos)
9. [Capa de Persistencia (Offline Support)](#9-capa-de-persistencia-offline-support)
10. [Fases de Implementación](#10-fases-de-implementación)
11. [Gestión de Errores y Estados](#11-gestión-de-errores-y-estados)
12. [Testing](#12-testing)
13. [Recursos y Assets](#13-recursos-y-assets)
14. [Estrategia de Subagentes (Desarrollo Paralelo)](#14-estrategia-de-subagentes-desarrollo-paralelo)
15. [Checklist de Entregables](#15-checklist-de-entregables)

---

## 1. Visión General del Proyecto

### 1.1. Descripción
Aplicación móvil nativa para **Android** e **iOS** que consume la API pública de Star Wars ([SWAPI](https://swapi.info)) para listar, buscar y visualizar el detalle de las películas de la saga Star Wars. El desarrollo se realiza **en paralelo** para ambas plataformas mediante el uso de **subagentes** independientes — un agente dedicado para Android y otro para iOS — trabajando simultáneamente sobre la misma especificación funcional.

### 1.2. Objetivos Funcionales
| ID | Funcionalidad | Descripción |
|----|---------------|-------------|
| F-01 | **Splash Screen** | Pantalla de bienvenida con logo/temática Star Wars al iniciar la app |
| F-02 | **Listado de Películas** | Lista paginada de todas las películas de Star Wars |
| F-03 | **Búsqueda de Películas** | Filtrar películas por título mediante campo de búsqueda |
| F-04 | **Paginación** | Paginación client-side del listado de películas |
| F-05 | **Detalle de Película** | Pantalla con información completa de la película seleccionada |
| F-06 | **Persistencia Local** | Caché offline de películas en base de datos local (Room / SwiftData) |
| F-07 | **Offline Support** | La app muestra datos cacheados cuando no hay conexión a internet |
| F-08 | **Estrategia Cache-First** | Carga datos locales primero, luego sincroniza con la API en segundo plano |

### 1.3. Stack Tecnológico

| Aspecto | Android | iOS |
|---------|---------|-----|
| **Lenguaje** | Kotlin | Swift |
| **UI Framework** | Jetpack Compose (Material 3) | SwiftUI |
| **Arquitectura** | Clean Architecture + MVVM | Clean Architecture + MVVM |
| **Networking** | Retrofit + OkHttp + Gson | URLSession nativo |
| **Async** | Coroutines + Flow | async/await + Combine |
| **DI** | Hilt (Dagger) | Swinject / Swift DI nativo |
| **Navegación** | Navigation Compose | NavigationStack |
| **Persistencia** | Room (SQLite) | SwiftData (Core Data) |
| **Min SDK/Target** | API 28 (Android 9) / API 36 | iOS 17+ |
| **Build** | Gradle (Kotlin DSL) | Xcode + SPM |
| **Testing** | JUnit + Mockk + Compose Testing | XCTest + XCUITest |

### 1.4. Configuración Actual del Proyecto Android
- **Package name:** `com.dam.starwarsapp`
- **AGP:** 8.13.2
- **Kotlin:** 2.0.21
- **Compile SDK:** 36
- **Min SDK:** 28
- **Target SDK:** 36
- **Java version:** 11
- **Compose BOM:** 2024.09.00

---

## 2. Análisis de la API (SWAPI)

### 2.1. Base URL
```
https://swapi.info/api
```

### 2.2. Endpoints Utilizados

| Método | Endpoint | Descripción | Respuesta |
|--------|----------|-------------|-----------|
| `GET` | `/films` | Obtener todas las películas | `Array<Film>` (6 elementos) |
| `GET` | `/films/{id}` | Obtener una película por ID | `Film` |

> **Nota importante:** La API devuelve las 6 películas en una única respuesta sin paginación server-side. La paginación se implementará en el **cliente**.

### 2.3. Estructura de Respuesta — Film

```json
{
  "title": "A New Hope",
  "episode_id": 4,
  "opening_crawl": "It is a period of civil war...",
  "director": "George Lucas",
  "producer": "Gary Kurtz, Rick McCallum",
  "release_date": "1977-05-25",
  "characters": ["https://swapi.info/api/people/1", ...],
  "planets": ["https://swapi.info/api/planets/1", ...],
  "starships": ["https://swapi.info/api/starships/2", ...],
  "vehicles": ["https://swapi.info/api/vehicles/4", ...],
  "species": ["https://swapi.info/api/species/1", ...],
  "created": "2014-12-10T14:23:31.880000Z",
  "edited": "2014-12-20T19:49:45.256000Z",
  "url": "https://swapi.info/api/films/1"
}
```

### 2.4. Catálogo Completo de Películas

| ID | Episodio | Título | Director | Fecha |
|----|----------|--------|----------|-------|
| 1 | IV | A New Hope | George Lucas | 1977-05-25 |
| 2 | V | The Empire Strikes Back | Irvin Kershner | 1980-05-17 |
| 3 | VI | Return of the Jedi | Richard Marquand | 1983-05-25 |
| 4 | I | The Phantom Menace | George Lucas | 1999-05-19 |
| 5 | II | Attack of the Clones | George Lucas | 2002-05-16 |
| 6 | III | Revenge of the Sith | George Lucas | 2005-05-19 |

### 2.5. Campos a Utilizar en la App

**En el listado (card):**
- `title` — Título de la película
- `episode_id` — Número de episodio (para mostrar "Episode I", "Episode II", etc.)
- `director` — Director
- `release_date` — Fecha de estreno

**En el detalle:**
- Todos los campos del listado, más:
- `opening_crawl` — Texto introductorio icónico
- `producer` — Productor(es)
- `characters` — Conteo de personajes (`characters.size`)
- `planets` — Conteo de planetas (`planets.size`)
- `starships` — Conteo de naves (`starships.size`)
- `vehicles` — Conteo de vehículos (`vehicles.size`)
- `species` — Conteo de especies (`species.size`)

### 2.6. Consideraciones de la API
- **No requiere autenticación** (API pública)
- **No tiene rate limiting** conocido
- **No soporta paginación server-side** para films
- **No tiene endpoint de búsqueda** para films → búsqueda client-side
- **HTTPS** obligatorio
- Los campos `characters`, `planets`, `starships`, `vehicles`, `species` son arrays de URLs (no objetos)
- Las fechas están en formato `YYYY-MM-DD` (release_date) e ISO 8601 (created/edited)

---

## 3. Arquitectura General

### 3.1. Patrón Arquitectónico: Clean Architecture + MVVM

```
┌─────────────────────────────────────────────────────────┐
│                      UI Layer                            │
│  ┌───────────┐  ┌──────────────┐  ┌──────────────────┐ │
│  │  Screens  │──│  ViewModels  │──│   State (sealed)  │ │
│  │ (Compose/ │  │              │  │   Loading/Success/ │ │
│  │  SwiftUI) │  │              │  │   Error/Empty      │ │
│  └───────────┘  └──────┬───────┘  └──────────────────┘ │
│                        │                                 │
├────────────────────────┼─────────────────────────────────┤
│                  Domain Layer                            │
│  ┌─────────────┐  ┌───┴───────────────────────┐         │
│  │   Models    │  │  Repository Interfaces     │         │
│  │  (Film.kt)  │  │  (FilmRepository.kt)       │         │
│  └─────────────┘  └───────────────────────────┘         │
│                                                          │
├──────────────────────────────────────────────────────────┤
│                    Data Layer                            │
│  ┌──────────────┐  ┌─────────────────────────┐          │
│  │   Remote     │  │  Repository Impl         │          │
│  │  (API DTOs)  │  │  (Offline-first logic)   │          │
│  └──────┬───────┘  └─────────┬───────────────┘          │
│         │                    │                           │
│  ┌──────┴───────┐  ┌────────┴───────────┐               │
│  │  API Service │  │  Local Database     │               │
│  │(StarWarsApi) │  │  (Room / SwiftData) │               │
│  └──────────────┘  └────────────────────┘               │
└──────────────────────────────────────────────────────────┘
```

### 3.2. Principios de Diseño
- **Separación de capas:** UI → Domain → Data
- **Inversión de dependencias:** La capa Domain define interfaces, Data las implementa
- **Single Source of Truth:** El ViewModel expone un único `UIState`
- **Unidirectional Data Flow (UDF):** Events (UI → VM) → State (VM → UI)
- **Inmutabilidad:** Los modelos de dominio y estados de UI son `data class` inmutables
- **Mapeo de DTOs:** Las respuestas de la API se mapean a modelos de dominio limpios

### 3.3. Flujo de Datos (Offline-First / Cache-First)

```
User Action → Screen → ViewModel → Repository
                ↑                       │
                │              ┌────────┼────────┐
                │              ▼                 ▼
                │        Local DB           API Service → SWAPI
                │         (Room/              │
                │        SwiftData)           │
                │              ↑              │
                │              └──── save ◄───┘
                │                     │
                └── UIState ◄─────────┘
```

**Estrategia de sincronización (Cache-First):**

1. **Primera carga:** ViewModel solicita datos al Repository
2. **Repository consulta local DB:** Si hay datos cacheados, los emite inmediatamente al UI
3. **Repository consulta API en paralelo:** Llama a SWAPI para obtener datos frescos
4. **Si la API responde con éxito:** Actualiza la local DB y emite los datos actualizados
5. **Si la API falla pero hay caché:** El UI ya tiene datos → no muestra error
6. **Si la API falla y NO hay caché:** El UI muestra estado de error con opción de retry
7. **Timestamp de última sincronización:** Se almacena para saber cuándo se actualizó por última vez

---

## 4. Diseño de Pantallas y Navegación

### 4.1. Mapa de Navegación

```
┌──────────────┐     auto       ┌──────────────────┐   tap film   ┌──────────────────┐
│              │  ──────────►   │                  │  ──────────►  │                  │
│ SplashScreen │               │  FilmListScreen  │              │ FilmDetailScreen  │
│              │               │                  │  ◄──────────  │                  │
└──────────────┘               └──────────────────┘    back       └──────────────────┘
```

### 4.2. Splash Screen

```
┌──────────────────────────────┐
│                              │
│                              │
│                              │
│        ★ STAR WARS ★         │
│                              │
│      [Logo / Animación]      │
│                              │
│                              │
│         Loading...           │
│                              │
└──────────────────────────────┘
```

**Especificaciones:**
- Duración: ~2 segundos (o hasta que la carga de datos inicial finalice)
- Fondo: Negro o degradado oscuro (temática Star Wars)
- Logo: Texto estilizado "STAR WARS" o imagen vectorial
- Animación: Fade-in del logo (opcional)
- **Android:** Usar `SplashScreen API` (androidx.core.splashscreen) + Composable custom para la animación extendida
- **iOS:** `LaunchScreen.storyboard` + vista SwiftUI animada

### 4.3. Pantalla de Listado de Películas (FilmListScreen)

```
┌──────────────────────────────┐
│  ★ Star Wars Films           │
├──────────────────────────────┤
│  🔍 [Buscar película...    ] │
├──────────────────────────────┤
│  ┌──────────────────────────┐│
│  │ Episode IV               ││
│  │ A New Hope               ││
│  │ Director: George Lucas   ││
│  │ 📅 1977-05-25        ▶  ││
│  └──────────────────────────┘│
│  ┌──────────────────────────┐│
│  │ Episode V                ││
│  │ The Empire Strikes Back  ││
│  │ Director: Irvin Kershner ││
│  │ 📅 1980-05-17        ▶  ││
│  └──────────────────────────┘│
│  ┌──────────────────────────┐│
│  │ Episode VI               ││
│  │ Return of the Jedi       ││
│  │ Director: Richard Mar... ││
│  │ 📅 1983-05-25        ▶  ││
│  └──────────────────────────┘│
├──────────────────────────────┤
│     ◀  Página 1 de 2  ▶     │
└──────────────────────────────┘
```

**Especificaciones:**
- **TopAppBar:** Título "Star Wars Films" con estilo temático
- **SearchBar:** Campo de texto para filtrado client-side por título
- **Lista:** `LazyColumn` (Android) / `List` (iOS) con cards para cada película
- **Card de película:** Muestra episode_id, title, director, release_date
- **Paginación:** Controles de paginación abajo (anterior/siguiente + indicador de página)
- **Items por página:** 3 películas por página (configurable)
- **Ordenamiento:** Por `episode_id` ascendente (orden cronológico in-universe)
- **Estados:** Loading, Error (con retry), Empty (sin resultados de búsqueda), Success
- **Pull to refresh:** Opcionalmente recargar desde la API

### 4.4. Pantalla de Detalle de Película (FilmDetailScreen)

```
┌──────────────────────────────┐
│  ← Back   Film Detail        │
├──────────────────────────────┤
│                              │
│       ★ Episode IV ★         │
│       A NEW HOPE             │
│                              │
├──────────────────────────────┤
│  Opening Crawl               │
│  ┌──────────────────────────┐│
│  │ It is a period of civil  ││
│  │ war. Rebel spaceships,   ││
│  │ striking from a hidden   ││
│  │ base, have won their     ││
│  │ first victory against    ││
│  │ the evil Galactic        ││
│  │ Empire...                ││
│  └──────────────────────────┘│
│                              │
│  Director    George Lucas    │
│  Producer    Gary Kurtz,     │
│              Rick McCallum   │
│  Release     May 25, 1977    │
│                              │
├──────────────────────────────┤
│  Stats                       │
│  👤 Characters    18         │
│  🌍 Planets        3         │
│  🚀 Starships      8         │
│  🚗 Vehicles       4         │
│  🧬 Species        5         │
│                              │
└──────────────────────────────┘
```

**Especificaciones:**
- **TopAppBar:** Botón de retroceso + título "Film Detail"
- **Header:** Número de episodio + Título en grande, estilo cinematográfico
- **Opening Crawl:** Sección scrolleable con el texto introductorio simulando el estilo Star Wars (texto amarillo sobre fondo oscuro, opcionalmente con perspectiva)
- **Info:** Director, Productor(es), Fecha de estreno formateada
- **Stats:** Conteo de personajes, planetas, naves, vehículos y especies (solo cantidad, no detalle)
- **Navegación por parámetro:** Se accede pasando el `filmId` (extraído de la URL del film)
- **Estados:** Loading, Error (con retry), Success

---

## 5. Plan Android — Desarrollo Activo

### 5.1. Estructura de Paquetes

```
android/app/src/main/java/com/dam/starwarsapp/
├── StarWarsApplication.kt              ← Application class (@HiltAndroidApp)
├── MainActivity.kt                     ← Activity principal (ya existe)
├── data/
│   ├── remote/
│   │   ├── StarWarsApi.kt              ← Interface Retrofit
│   │   └── dto/
│   │       └── FilmDto.kt              ← DTO de la respuesta API
│   ├── local/
│   │   ├── StarWarsDatabase.kt         ← Base de datos Room
│   │   ├── dao/
│   │   │   └── FilmDao.kt             ← DAO de acceso a films
│   │   └── entity/
│   │       └── FilmEntity.kt          ← Entidad Room para films
│   └── repository/
│       └── FilmRepositoryImpl.kt       ← Implementación del repositorio (offline-first)
├── domain/
│   ├── model/
│   │   └── Film.kt                     ← Modelo de dominio
│   └── repository/
│       └── FilmRepository.kt           ← Interface del repositorio
├── di/
│   ├── AppModule.kt                    ← Módulo Hilt (Retrofit, Repo, etc.)
│   └── DatabaseModule.kt              ← Módulo Hilt (Room DB, DAOs)
└── ui/
    ├── navigation/
    │   ├── Screen.kt                   ← Sealed class de rutas
    │   └── NavGraph.kt                 ← Grafo de navegación Compose
    ├── splash/
    │   └── SplashScreen.kt             ← Composable de splash
    ├── films/
    │   ├── FilmListScreen.kt           ← Composable del listado
    │   ├── FilmListViewModel.kt        ← ViewModel con paginación y búsqueda
    │   └── components/
    │       ├── FilmCard.kt             ← Card individual de película
    │       ├── SearchBar.kt            ← Barra de búsqueda
    │       └── PaginationControls.kt   ← Controles de paginación
    ├── detail/
    │   ├── FilmDetailScreen.kt         ← Composable del detalle
    │   └── FilmDetailViewModel.kt      ← ViewModel del detalle
    ├── components/
    │   ├── LoadingIndicator.kt         ← Indicador de carga reutilizable
    │   └── ErrorMessage.kt             ← Mensaje de error reutilizable
    └── theme/
        ├── Color.kt                    ← (ya existe) Colores temáticos
        ├── Theme.kt                    ← (ya existe) Tema Material 3
        └── Type.kt                     ← (ya existe) Tipografía
```

### 5.2. Dependencias a Añadir

#### `gradle/libs.versions.toml` — Nuevas entradas:

```toml
[versions]
# ... existentes ...
retrofit = "2.11.0"
okhttp = "4.12.0"
hilt = "2.51.1"
hiltNavigationCompose = "1.2.0"
navigationCompose = "2.8.5"
coroutines = "1.9.0"
splashscreen = "1.0.1"
coil = "2.7.0"
room = "2.6.1"

[libraries]
# Networking
retrofit-core = { group = "com.squareup.retrofit2", name = "retrofit", version.ref = "retrofit" }
retrofit-converter-gson = { group = "com.squareup.retrofit2", name = "converter-gson", version.ref = "retrofit" }
okhttp-logging = { group = "com.squareup.okhttp3", name = "logging-interceptor", version.ref = "okhttp" }

# DI - Hilt
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }
hilt-compiler = { group = "com.google.dagger", name = "hilt-android-compiler", version.ref = "hilt" }
hilt-navigation-compose = { group = "androidx.hilt", name = "hilt-navigation-compose", version.ref = "hiltNavigationCompose" }

# Navigation
navigation-compose = { group = "androidx.navigation", name = "navigation-compose", version.ref = "navigationCompose" }

# Coroutines
coroutines-core = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-core", version.ref = "coroutines" }
coroutines-android = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-android", version.ref = "coroutines" }

# Splash Screen
splashscreen = { group = "androidx.core", name = "core-splashscreen", version.ref = "splashscreen" }

# Images (opcional)
coil-compose = { group = "io.coil-kt", name = "coil-compose", version.ref = "coil" }

# Room (Persistencia local)
room-runtime = { group = "androidx.room", name = "room-runtime", version.ref = "room" }
room-compiler = { group = "androidx.room", name = "room-compiler", version.ref = "room" }
room-ktx = { group = "androidx.room", name = "room-ktx", version.ref = "room" }

[plugins]
# ... existentes ...
hilt = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
ksp = { id = "com.google.devtools.ksp", version = "2.0.21-1.0.28" }
```

#### `android/app/build.gradle.kts` — Nuevas dependencias:

```kotlin
plugins {
    // ... existentes ...
    alias(libs.plugins.hilt)
    alias(libs.plugins.ksp)
}

dependencies {
    // ... existentes ...

    // Networking
    implementation(libs.retrofit.core)
    implementation(libs.retrofit.converter.gson)
    implementation(libs.okhttp.logging)

    // DI
    implementation(libs.hilt.android)
    ksp(libs.hilt.compiler)
    implementation(libs.hilt.navigation.compose)

    // Navigation
    implementation(libs.navigation.compose)

    // Coroutines
    implementation(libs.coroutines.core)
    implementation(libs.coroutines.android)

    // Splash Screen
    implementation(libs.splashscreen)

    // Images (opcional)
    implementation(libs.coil.compose)

    // Room (Persistencia local)
    implementation(libs.room.runtime)
    implementation(libs.room.ktx)
    ksp(libs.room.compiler)
}
```

#### `android/build.gradle.kts` (root) — Nuevo plugin:

```kotlin
plugins {
    // ... existentes ...
    alias(libs.plugins.hilt) apply false
    alias(libs.plugins.ksp) apply false
}
```

### 5.3. Detalle de Implementación por Archivo

---

#### 5.3.1. `StarWarsApplication.kt`
```kotlin
@HiltAndroidApp
class StarWarsApplication : Application()
```
- Registrar en `AndroidManifest.xml` con `android:name=".StarWarsApplication"`
- Punto de entrada para la inyección de dependencias de Hilt

---

#### 5.3.2. `data/remote/dto/FilmDto.kt`
```kotlin
data class FilmDto(
    val title: String,
    @SerializedName("episode_id") val episodeId: Int,
    @SerializedName("opening_crawl") val openingCrawl: String,
    val director: String,
    val producer: String,
    @SerializedName("release_date") val releaseDate: String,
    val characters: List<String>,
    val planets: List<String>,
    val starships: List<String>,
    val vehicles: List<String>,
    val species: List<String>,
    val url: String
)
```
- Mapeo completo de la respuesta JSON
- Usa `@SerializedName` para campos snake_case
- Función de extensión `toDomain(): Film` para convertir a modelo de dominio

---

#### 5.3.3. `data/remote/StarWarsApi.kt`
```kotlin
interface StarWarsApi {
    @GET("films")
    suspend fun getFilms(): List<FilmDto>

    @GET("films/{id}")
    suspend fun getFilmById(@Path("id") id: Int): FilmDto
}
```
- Interface Retrofit con funciones `suspend`
- Base URL: `https://swapi.info/api/`
- La respuesta de `/films` es directamente un `List<FilmDto>` (no envuelta en paginación)

---

#### 5.3.4. `domain/model/Film.kt`
```kotlin
data class Film(
    val id: Int,
    val title: String,
    val episodeId: Int,
    val openingCrawl: String,
    val director: String,
    val producer: String,
    val releaseDate: String,
    val charactersCount: Int,
    val planetsCount: Int,
    val starshipsCount: Int,
    val vehiclesCount: Int,
    val speciesCount: Int
)
```
- Modelo limpio de dominio
- Los arrays de URLs se convierten en conteos (`List<String>.size`)
- El `id` se extrae del campo `url` (ej: `".../films/1"` → `1`)

---

#### 5.3.5. `domain/repository/FilmRepository.kt`
```kotlin
interface FilmRepository {
    fun getFilms(): Flow<Resource<List<Film>>>
    fun getFilmById(id: Int): Flow<Resource<Film>>
}
```
- Interface en la capa Domain
- Devuelve `Flow<Resource<T>>` para soporte reactivo y offline-first
- No conoce Retrofit, Room ni DTOs

---

#### 5.3.6. `data/repository/FilmRepositoryImpl.kt`

> **Nota:** La implementación completa con lógica offline-first se detalla en §5.3.12.

- Implementa la interface del Domain
- Inyección por constructor con `@Inject` (StarWarsApi + FilmDao)
- Lógica cache-first: emite datos locales → consulta API → actualiza caché → emite datos frescos
- Manejo robusto de errores de red con fallback a datos cacheados

---

#### 5.3.7. `di/AppModule.kt`
```kotlin
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(HttpLoggingInterceptor().apply {
                level = HttpLoggingInterceptor.Level.BODY
            })
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl("https://swapi.info/api/")
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    @Provides
    @Singleton
    fun provideStarWarsApi(retrofit: Retrofit): StarWarsApi {
        return retrofit.create(StarWarsApi::class.java)
    }

    @Provides
    @Singleton
    fun provideFilmRepository(api: StarWarsApi, filmDao: FilmDao): FilmRepository {
        return FilmRepositoryImpl(api, filmDao)
    }
}
```
- Módulo Hilt con scope `SingletonComponent`
- Provee: OkHttpClient, Retrofit, StarWarsApi, FilmRepository
- Logging habilitado para debug
- Timeouts configurados

---

#### 5.3.8. `di/DatabaseModule.kt`
```kotlin
@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideStarWarsDatabase(@ApplicationContext context: Context): StarWarsDatabase {
        return Room.databaseBuilder(
            context,
            StarWarsDatabase::class.java,
            "star_wars_database"
        ).build()
    }

    @Provides
    @Singleton
    fun provideFilmDao(database: StarWarsDatabase): FilmDao {
        return database.filmDao()
    }
}
```
- Módulo Hilt separado para la base de datos
- Provee: StarWarsDatabase (singleton), FilmDao
- Nombre de la DB: `star_wars_database`

---

#### 5.3.9. `data/local/entity/FilmEntity.kt`
```kotlin
@Entity(tableName = "films")
data class FilmEntity(
    @PrimaryKey val id: Int,
    val title: String,
    @ColumnInfo(name = "episode_id") val episodeId: Int,
    @ColumnInfo(name = "opening_crawl") val openingCrawl: String,
    val director: String,
    val producer: String,
    @ColumnInfo(name = "release_date") val releaseDate: String,
    @ColumnInfo(name = "characters_count") val charactersCount: Int,
    @ColumnInfo(name = "planets_count") val planetsCount: Int,
    @ColumnInfo(name = "starships_count") val starshipsCount: Int,
    @ColumnInfo(name = "vehicles_count") val vehiclesCount: Int,
    @ColumnInfo(name = "species_count") val speciesCount: Int,
    @ColumnInfo(name = "last_updated") val lastUpdated: Long = System.currentTimeMillis()
)
```
- Entidad Room mapeada a la tabla `films`
- Primary key: `id` (extraído de la URL de la API)
- Incluye `lastUpdated` (timestamp) para controlar cuándo se actualizó el registro
- `@ColumnInfo` con nombres snake_case para consistencia con SQLite

**Funciones de mapeo:**
```kotlin
fun FilmEntity.toDomain(): Film { ... }
fun Film.toEntity(): FilmEntity { ... }
fun FilmDto.toEntity(): FilmEntity { ... }
```

---

#### 5.3.10. `data/local/dao/FilmDao.kt`
```kotlin
@Dao
interface FilmDao {
    @Query("SELECT * FROM films ORDER BY episode_id ASC")
    fun getAllFilms(): Flow<List<FilmEntity>>

    @Query("SELECT * FROM films WHERE id = :filmId")
    fun getFilmById(filmId: Int): Flow<FilmEntity?>

    @Query("SELECT * FROM films WHERE title LIKE '%' || :query || '%'")
    fun searchFilms(query: String): Flow<List<FilmEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertFilms(films: List<FilmEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertFilm(film: FilmEntity)

    @Query("DELETE FROM films")
    suspend fun deleteAllFilms()

    @Query("SELECT COUNT(*) FROM films")
    suspend fun getFilmCount(): Int

    @Query("SELECT MAX(last_updated) FROM films")
    suspend fun getLastUpdateTimestamp(): Long?
}
```
- Retorna `Flow<List<FilmEntity>>` para observar cambios reactivamente
- `OnConflictStrategy.REPLACE` para upsert (actualizar si ya existe)
- Método `searchFilms` con LIKE para búsqueda local
- `getLastUpdateTimestamp` para decidir si refrescar desde la API
- `getFilmCount` para saber si hay datos en caché

---

#### 5.3.11. `data/local/StarWarsDatabase.kt`
```kotlin
@Database(
    entities = [FilmEntity::class],
    version = 1,
    exportSchema = false
)
abstract class StarWarsDatabase : RoomDatabase() {
    abstract fun filmDao(): FilmDao
}
```
- Base de datos Room con la entidad `FilmEntity`
- Versión 1 (sin migraciones necesarias al inicio)
- `exportSchema = false` para desarrollo (habilitar para producción)

---

#### 5.3.12. `data/repository/FilmRepositoryImpl.kt` (Actualizado con Offline-First)
```kotlin
class FilmRepositoryImpl @Inject constructor(
    private val api: StarWarsApi,
    private val filmDao: FilmDao
) : FilmRepository {

    override fun getFilms(): Flow<Resource<List<Film>>> = flow {
        emit(Resource.Loading())

        // 1. Emitir datos cacheados primero (si existen)
        val cachedFilms = filmDao.getAllFilms().first()
        if (cachedFilms.isNotEmpty()) {
            emit(Resource.Success(cachedFilms.map { it.toDomain() }))
        }

        // 2. Intentar obtener datos frescos de la API
        try {
            val remoteFilms = api.getFilms()
            // 3. Guardar en caché local
            filmDao.insertFilms(remoteFilms.map { it.toEntity() })
            // 4. Emitir datos actualizados desde la DB
            val updatedFilms = filmDao.getAllFilms().first()
            emit(Resource.Success(updatedFilms.map { it.toDomain() }))
        } catch (e: Exception) {
            // 5. Si falla la API y no hay caché → error
            if (cachedFilms.isEmpty()) {
                emit(Resource.Error(e.message ?: "Error desconocido"))
            }
            // Si hay caché, ya se emitió en el paso 1 → silenciar error
        }
    }

    override fun getFilmById(id: Int): Flow<Resource<Film>> = flow {
        emit(Resource.Loading())

        // 1. Emitir dato cacheado primero
        val cachedFilm = filmDao.getFilmById(id).first()
        if (cachedFilm != null) {
            emit(Resource.Success(cachedFilm.toDomain()))
        }

        // 2. Intentar obtener dato fresco de la API
        try {
            val remoteFilm = api.getFilmById(id)
            filmDao.insertFilm(remoteFilm.toEntity())
            val updatedFilm = filmDao.getFilmById(id).first()
            if (updatedFilm != null) {
                emit(Resource.Success(updatedFilm.toDomain()))
            }
        } catch (e: Exception) {
            if (cachedFilm == null) {
                emit(Resource.Error(e.message ?: "Error desconocido"))
            }
        }
    }
}
```

**Clase Resource (wrapper):**
```kotlin
sealed class Resource<T>(val data: T? = null, val message: String? = null) {
    class Loading<T>(data: T? = null) : Resource<T>(data)
    class Success<T>(data: T) : Resource<T>(data)
    class Error<T>(message: String, data: T? = null) : Resource<T>(data, message)
}
```
- Patrón **Resource** para representar Loading, Success, Error con datos opcionales
- Permite emitir datos cacheados incluso durante un error de red

---

#### 5.3.13. `ui/navigation/Screen.kt`
```kotlin
sealed class Screen(val route: String) {
    object Splash : Screen("splash")
    object FilmList : Screen("film_list")
    object FilmDetail : Screen("film_detail/{filmId}") {
        fun createRoute(filmId: Int) = "film_detail/$filmId"
    }
}
```
- Sealed class con todas las rutas de navegación
- `FilmDetail` recibe `filmId` como argumento de navegación

---

#### 5.3.14. `ui/navigation/NavGraph.kt`
```kotlin
@Composable
fun NavGraph(navController: NavHostController) {
    NavHost(
        navController = navController,
        startDestination = Screen.Splash.route
    ) {
        composable(Screen.Splash.route) {
            SplashScreen(
                onSplashFinished = {
                    navController.navigate(Screen.FilmList.route) {
                        popUpTo(Screen.Splash.route) { inclusive = true }
                    }
                }
            )
        }
        composable(Screen.FilmList.route) {
            FilmListScreen(
                onFilmClick = { filmId ->
                    navController.navigate(Screen.FilmDetail.createRoute(filmId))
                }
            )
        }
        composable(
            route = Screen.FilmDetail.route,
            arguments = listOf(navArgument("filmId") { type = NavType.IntType })
        ) {
            FilmDetailScreen(
                onBackClick = { navController.popBackStack() }
            )
        }
    }
}
```
- `NavHost` con 3 destinos: Splash → FilmList → FilmDetail
- El Splash se auto-navega al FilmList y se elimina del backstack
- FilmDetail recibe `filmId` como argumento tipado (Int)

---

#### 5.3.15. `ui/splash/SplashScreen.kt`

**Comportamiento:**
1. Mostrar fondo oscuro (negro/space-themed)
2. Animación Fade-in del título "STAR WARS"
3. Indicador de progreso sutil
4. Después de ~2s (o animación completa), invocar `onSplashFinished`

**Implementación Android nativa:**
- Modificar `themes.xml` para configurar el `windowSplashScreen*` (fase del sistema)
- Usar `installSplashScreen()` en `MainActivity.onCreate()`
- Composable custom para la parte animada post-splash del sistema
- `LaunchedEffect` con `delay(2000)` para temporizar la transición

---

#### 5.3.16. `ui/films/FilmListViewModel.kt`

```kotlin
@HiltViewModel
class FilmListViewModel @Inject constructor(
    private val repository: FilmRepository
) : ViewModel() {

    // Estado interno
    private val _uiState = MutableStateFlow<FilmListUiState>(FilmListUiState.Loading)
    val uiState: StateFlow<FilmListUiState> = _uiState.asStateFlow()

    // Búsqueda
    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    // Paginación
    private val _currentPage = MutableStateFlow(1)
    val currentPage: StateFlow<Int> = _currentPage.asStateFlow()

    val itemsPerPage = 3

    // Todos los films cargados
    private var allFilms: List<Film> = emptyList()

    init {
        loadFilms()
    }

    fun loadFilms() { /* fetch + emit state */ }
    fun onSearchQueryChange(query: String) { /* filtrar + resetear página */ }
    fun onNextPage() { /* _currentPage.value++ */ }
    fun onPreviousPage() { /* _currentPage.value-- */ }

    // Computed: films filtrados y paginados
    private fun updatePaginatedState() { /* combinar búsqueda + paginación */ }
}
```

**UIState sealed:**
```kotlin
sealed class FilmListUiState {
    object Loading : FilmListUiState()
    data class Success(
        val films: List<Film>,       // Films de la página actual
        val currentPage: Int,
        val totalPages: Int,
        val searchQuery: String
    ) : FilmListUiState()
    data class Error(val message: String) : FilmListUiState()
}
```

---

#### 5.3.17. `ui/films/FilmListScreen.kt`

**Composables internos:**
- `FilmListScreen` — Composable raíz con Scaffold
- Usa `TopAppBar` con título
- Integra `SearchBar`, `LazyColumn` de `FilmCard`, y `PaginationControls`
- Observa `uiState` del ViewModel con `collectAsStateWithLifecycle()`
- Muestra `LoadingIndicator`, `ErrorMessage`, o la lista según el estado

---

#### 5.3.18. `ui/films/components/FilmCard.kt`

```kotlin
@Composable
fun FilmCard(
    film: Film,
    onClick: () -> Unit
)
```
- `Card` de Material 3 con `onClick`
- Muestra: Episode {romanNumeral}, título en negrita, director, fecha
- Icono de flecha a la derecha indicando navegación
- Elevation y shape redondeado

---

#### 5.3.19. `ui/films/components/SearchBar.kt`

```kotlin
@Composable
fun FilmSearchBar(
    query: String,
    onQueryChange: (String) -> Unit
)
```
- `OutlinedTextField` con icono de búsqueda
- Placeholder: "Buscar película..."
- Botón de limpiar (X) cuando hay texto
- Debounce opcional para optimizar filtrado

---

#### 5.3.20. `ui/films/components/PaginationControls.kt`

```kotlin
@Composable
fun PaginationControls(
    currentPage: Int,
    totalPages: Int,
    onPreviousPage: () -> Unit,
    onNextPage: () -> Unit
)
```
- Row con: Botón "←" | Texto "Página X de Y" | Botón "→"
- Botones deshabilitados en primera/última página
- Estilo compacto y centrado

---

#### 5.3.21. `ui/detail/FilmDetailViewModel.kt`

```kotlin
@HiltViewModel
class FilmDetailViewModel @Inject constructor(
    private val repository: FilmRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val filmId: Int = savedStateHandle.get<Int>("filmId") ?: -1

    private val _uiState = MutableStateFlow<FilmDetailUiState>(FilmDetailUiState.Loading)
    val uiState: StateFlow<FilmDetailUiState> = _uiState.asStateFlow()

    init {
        loadFilm()
    }

    fun loadFilm() { /* fetch film by id */ }
}
```

**UIState sealed:**
```kotlin
sealed class FilmDetailUiState {
    object Loading : FilmDetailUiState()
    data class Success(val film: Film) : FilmDetailUiState()
    data class Error(val message: String) : FilmDetailUiState()
}
```

---

#### 5.3.22. `ui/detail/FilmDetailScreen.kt`

**Layout:**
- `Scaffold` con `TopAppBar` (back button + "Film Detail")
- Contenido scrolleable (`Column` con `verticalScroll`)
- Header: Episode number + Título
- Sección Opening Crawl: fondo oscuro, texto amarillo, scroll interno
- Sección Info: Director, Producer, Release Date (formateado a locale)
- Sección Stats: Grid/Column con iconos + conteos (Characters, Planets, etc.)

---

#### 5.3.23. `ui/components/LoadingIndicator.kt`
```kotlin
@Composable
fun LoadingIndicator()
```
- `Box` centrado con `CircularProgressIndicator`
- Color temático (amarillo Star Wars)

---

#### 5.3.24. `ui/components/ErrorMessage.kt`
```kotlin
@Composable
fun ErrorMessage(
    message: String,
    onRetry: () -> Unit
)
```
- Texto de error + botón "Reintentar"
- Icono de warning
- Centrado en pantalla

---

#### 5.3.25. `MainActivity.kt` — Modificaciones

```kotlin
@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        val splashScreen = installSplashScreen()
        super.onCreate(savedInstanceState)

        enableEdgeToEdge()

        setContent {
            StarWarsAppTheme {
                val navController = rememberNavController()
                NavGraph(navController = navController)
            }
        }
    }
}
```
- Añadir `@AndroidEntryPoint` para Hilt
- Instalar `SplashScreen API` del sistema
- Reemplazar el `Scaffold/Greeting` actual por `NavGraph`

---

#### 5.3.26. Tema — Actualización de Colores

**Paleta Star Wars sugerida:**

```kotlin
// Color.kt
val StarWarsYellow = Color(0xFFFFE81F)     // Amarillo icónico
val StarWarsBlack = Color(0xFF000000)       // Negro espacio
val StarWarsDarkGray = Color(0xFF1A1A2E)    // Gris oscuro fondo
val StarWarsLightGray = Color(0xFFB0B0B0)   // Gris claro texto
val StarWarsBlue = Color(0xFF0D47A1)        // Azul lado luminoso
val StarWarsRed = Color(0xFFC62828)         // Rojo lado oscuro
val StarWarsCardBg = Color(0xFF16213E)      // Fondo de cards
```

### 5.4. AndroidManifest.xml — Cambios Necesarios

```xml
<application
    android:name=".StarWarsApplication"
    android:theme="@style/Theme.StarWarsApp"
    ... >
    <activity
        android:name=".MainActivity"
        android:exported="true"
        android:theme="@style/Theme.App.Starting"
        ... >
    </activity>
</application>
```
- Añadir `android:name=".StarWarsApplication"` en `<application>`
- Tema de splash en la Activity: `Theme.App.Starting`

### 5.5. Resources — Añadidos

```
res/values/themes.xml → Añadir Theme.App.Starting con windowSplashScreen*
res/values/colors.xml → Añadir colores Star Wars
res/drawable/splash_icon.xml → Icono/logo para splash (VectorDrawable)
```

---

## 6. Plan iOS — Desarrollo Activo

> **ESTADO: ACTIVO** — Se desarrolla en paralelo con Android mediante un subagente dedicado.

### 6.1. Requisitos del Entorno
- **Xcode:** 15+ (recomendado 16+)
- **Swift:** 5.9+
- **Deployment Target:** iOS 17.0
- **Gestión de dependencias:** Swift Package Manager (SPM)
- **Persistencia:** SwiftData (requiere iOS 17+)

### 6.2. Estructura del Proyecto

```
iOS/StarWarsApp/
├── StarWarsApp.xcodeproj
├── StarWarsApp/
│   ├── StarWarsAppApp.swift               ← Entry point (@main) con ModelContainer
│   ├── ContentView.swift                  ← Root view
│   ├── Info.plist
│   ├── Data/
│   │   ├── Remote/
│   │   │   ├── StarWarsAPIService.swift   ← Networking con URLSession
│   │   │   └── DTO/
│   │   │       └── FilmDTO.swift          ← Decodable DTO
│   │   ├── Local/
│   │   │   ├── FilmSwiftDataModel.swift   ← Modelo SwiftData (@Model)
│   │   │   └── FilmLocalDataSource.swift  ← Operaciones CRUD sobre SwiftData
│   │   └── Repository/
│   │       └── FilmRepositoryImpl.swift   ← Implementación repositorio (offline-first)
│   ├── Domain/
│   │   ├── Model/
│   │   │   └── Film.swift                 ← Modelo de dominio
│   │   └── Repository/
│   │       └── FilmRepository.swift       ← Protocol del repositorio
│   ├── DI/
│   │   └── DependencyContainer.swift      ← Container de DI manual o Swinject
│   ├── UI/
│   │   ├── Navigation/
│   │   │   └── AppRouter.swift            ← NavigationStack routing
│   │   ├── Splash/
│   │   │   └── SplashView.swift           ← Vista de splash
│   │   ├── Films/
│   │   │   ├── FilmListView.swift         ← Vista de listado
│   │   │   ├── FilmListViewModel.swift    ← ViewModel con @Published
│   │   │   └── Components/
│   │   │       ├── FilmCardView.swift     ← Card de película
│   │   │       ├── SearchBarView.swift    ← Barra de búsqueda
│   │   │       └── PaginationView.swift   ← Controles paginación
│   │   ├── Detail/
│   │   │   ├── FilmDetailView.swift       ← Vista de detalle
│   │   │   └── FilmDetailViewModel.swift  ← ViewModel del detalle
│   │   ├── Components/
│   │   │   ├── LoadingView.swift          ← Indicador de carga
│   │   │   └── ErrorView.swift            ← Vista de error
│   │   └── Theme/
│   │       ├── StarWarsColors.swift       ← Extensión de Color
│   │       └── StarWarsFonts.swift        ← Fuentes personalizadas
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   ├── StarWarsLogo.imageset/
│   │   └── Colors/
│   ├── Preview Content/
│   └── LaunchScreen.storyboard
├── StarWarsAppTests/
│   ├── FilmRepositoryTests.swift
│   ├── FilmListViewModelTests.swift
│   └── FilmDetailViewModelTests.swift
└── StarWarsAppUITests/
    ├── FilmListUITests.swift
    └── FilmDetailUITests.swift
```

### 6.3. Detalle de Implementación iOS

#### 6.3.1. `Data/Remote/DTO/FilmDTO.swift`
```swift
struct FilmDTO: Decodable {
    let title: String
    let episodeId: Int
    let openingCrawl: String
    let director: String
    let producer: String
    let releaseDate: String
    let characters: [String]
    let planets: [String]
    let starships: [String]
    let vehicles: [String]
    let species: [String]
    let url: String

    enum CodingKeys: String, CodingKey {
        case title, director, producer, characters, planets,
             starships, vehicles, species, url
        case episodeId = "episode_id"
        case openingCrawl = "opening_crawl"
        case releaseDate = "release_date"
    }

    func toDomain() -> Film { ... }
}
```

#### 6.3.2. `Data/Remote/StarWarsAPIService.swift`
```swift
protocol StarWarsAPIServiceProtocol {
    func fetchFilms() async throws -> [FilmDTO]
    func fetchFilm(id: Int) async throws -> FilmDTO
}

class StarWarsAPIService: StarWarsAPIServiceProtocol {
    private let baseURL = "https://swapi.info/api"
    private let session: URLSession

    func fetchFilms() async throws -> [FilmDTO] {
        let url = URL(string: "\(baseURL)/films")!
        let (data, _) = try await session.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode([FilmDTO].self, from: data)
    }

    func fetchFilm(id: Int) async throws -> FilmDTO {
        let url = URL(string: "\(baseURL)/films/\(id)")!
        let (data, _) = try await session.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(FilmDTO.self, from: data)
    }
}
```

#### 6.3.3. `Domain/Model/Film.swift`
```swift
struct Film: Identifiable, Equatable {
    let id: Int
    let title: String
    let episodeId: Int
    let openingCrawl: String
    let director: String
    let producer: String
    let releaseDate: String
    let charactersCount: Int
    let planetsCount: Int
    let starshipsCount: Int
    let vehiclesCount: Int
    let speciesCount: Int
}
```

#### 6.3.4. `Domain/Repository/FilmRepository.swift`
```swift
protocol FilmRepository {
    func getFilms() async -> Result<[Film], Error>
    func getFilmById(_ id: Int) async -> Result<Film, Error>
}
```

#### 6.3.5. `UI/Films/FilmListViewModel.swift`
```swift
@MainActor
class FilmListViewModel: ObservableObject {
    @Published var uiState: FilmListUiState = .loading
    @Published var searchQuery: String = ""
    @Published var currentPage: Int = 1

    let itemsPerPage = 3
    private var allFilms: [Film] = []
    private let repository: FilmRepository

    func loadFilms() async { ... }
    func onSearchQueryChange(_ query: String) { ... }
    func nextPage() { ... }
    func previousPage() { ... }
}

enum FilmListUiState {
    case loading
    case success(films: [Film], currentPage: Int, totalPages: Int)
    case error(String)
}
```

#### 6.3.6. `UI/Films/FilmListView.swift`
```swift
struct FilmListView: View {
    @StateObject private var viewModel: FilmListViewModel

    var body: some View {
        NavigationStack {
            VStack {
                SearchBarView(text: $viewModel.searchQuery)
                switch viewModel.uiState {
                case .loading: LoadingView()
                case .success(let films, let page, let total):
                    List(films) { film in
                        NavigationLink(value: film.id) {
                            FilmCardView(film: film)
                        }
                    }
                    PaginationView(current: page, total: total, ...)
                case .error(let msg): ErrorView(message: msg, onRetry: { ... })
                }
            }
            .navigationTitle("Star Wars Films")
            .navigationDestination(for: Int.self) { filmId in
                FilmDetailView(filmId: filmId)
            }
        }
    }
}
```

#### 6.3.7. `UI/Detail/FilmDetailView.swift`
```swift
struct FilmDetailView: View {
    @StateObject private var viewModel: FilmDetailViewModel

    var body: some View {
        ScrollView {
            switch viewModel.uiState {
            case .loading: LoadingView()
            case .success(let film):
                VStack(spacing: 16) {
                    // Header: Episode + Title
                    // Opening Crawl section
                    // Info: Director, Producer, Release Date
                    // Stats grid: Characters, Planets, etc.
                }
            case .error(let msg): ErrorView(message: msg, onRetry: { ... })
            }
        }
        .navigationTitle("Film Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

### 6.4. Persistencia con SwiftData

#### 6.4.1. `Data/Local/FilmSwiftDataModel.swift`
```swift
import SwiftData

@Model
final class FilmSwiftDataModel {
    @Attribute(.unique) var id: Int
    var title: String
    var episodeId: Int
    var openingCrawl: String
    var director: String
    var producer: String
    var releaseDate: String
    var charactersCount: Int
    var planetsCount: Int
    var starshipsCount: Int
    var vehiclesCount: Int
    var speciesCount: Int
    var lastUpdated: Date

    init(id: Int, title: String, episodeId: Int, openingCrawl: String,
         director: String, producer: String, releaseDate: String,
         charactersCount: Int, planetsCount: Int, starshipsCount: Int,
         vehiclesCount: Int, speciesCount: Int, lastUpdated: Date = .now) {
        self.id = id
        self.title = title
        self.episodeId = episodeId
        self.openingCrawl = openingCrawl
        self.director = director
        self.producer = producer
        self.releaseDate = releaseDate
        self.charactersCount = charactersCount
        self.planetsCount = planetsCount
        self.starshipsCount = starshipsCount
        self.vehiclesCount = vehiclesCount
        self.speciesCount = speciesCount
        self.lastUpdated = lastUpdated
    }

    func toDomain() -> Film { ... }
}

extension Film {
    func toSwiftDataModel() -> FilmSwiftDataModel { ... }
}

extension FilmDTO {
    func toSwiftDataModel() -> FilmSwiftDataModel { ... }
}
```
- `@Model` macro de SwiftData para persistencia automática
- `@Attribute(.unique)` en `id` para garantizar upsert (no duplicados)
- `lastUpdated` para control de frescura del caché

#### 6.4.2. `Data/Local/FilmLocalDataSource.swift`
```swift
import SwiftData

actor FilmLocalDataSource {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }

    func fetchAllFilms() throws -> [FilmSwiftDataModel] {
        let descriptor = FetchDescriptor<FilmSwiftDataModel>(
            sortBy: [SortDescriptor(\.episodeId)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchFilm(byId id: Int) throws -> FilmSwiftDataModel? {
        let descriptor = FetchDescriptor<FilmSwiftDataModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func saveFilms(_ films: [FilmSwiftDataModel]) throws {
        for film in films {
            modelContext.insert(film)
        }
        try modelContext.save()
    }

    func deleteAllFilms() throws {
        try modelContext.delete(model: FilmSwiftDataModel.self)
        try modelContext.save()
    }

    func getFilmCount() throws -> Int {
        let descriptor = FetchDescriptor<FilmSwiftDataModel>()
        return try modelContext.fetchCount(descriptor)
    }
}
```
- **Actor** para thread-safety en operaciones de datos
- Usa `FetchDescriptor` con predicados y ordenamiento
- `#Predicate` type-safe para consultas
- `ModelContext` gestionado localmente por el actor

#### 6.4.3. `StarWarsAppApp.swift` — Configuración de ModelContainer
```swift
import SwiftUI
import SwiftData

@main
struct StarWarsAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [FilmSwiftDataModel.self])
    }
}
```

#### 6.4.4. `Data/Repository/FilmRepositoryImpl.swift` (Offline-First)
```swift
class FilmRepositoryImpl: FilmRepository {
    private let apiService: StarWarsAPIServiceProtocol
    private let localDataSource: FilmLocalDataSource

    init(apiService: StarWarsAPIServiceProtocol, localDataSource: FilmLocalDataSource) {
        self.apiService = apiService
        self.localDataSource = localDataSource
    }

    func getFilms() async -> Result<[Film], Error> {
        // 1. Intentar obtener datos locales
        let cachedFilms = (try? await localDataSource.fetchAllFilms()) ?? []

        // 2. Intentar obtener datos de la API
        do {
            let remoteFilms = try await apiService.fetchFilms()
            let models = remoteFilms.map { $0.toSwiftDataModel() }
            try await localDataSource.deleteAllFilms()
            try await localDataSource.saveFilms(models)
            let updatedFilms = try await localDataSource.fetchAllFilms()
            return .success(updatedFilms.map { $0.toDomain() })
        } catch {
            // 3. Si falla la API, devolver caché si existe
            if !cachedFilms.isEmpty {
                return .success(cachedFilms.map { $0.toDomain() })
            }
            return .failure(error)
        }
    }

    func getFilmById(_ id: Int) async -> Result<Film, Error> {
        // Misma lógica cache-first para un solo film
        let cachedFilm = try? await localDataSource.fetchFilm(byId: id)

        do {
            let remoteFilm = try await apiService.fetchFilm(id: id)
            let model = remoteFilm.toSwiftDataModel()
            try await localDataSource.saveFilms([model])
            if let updated = try await localDataSource.fetchFilm(byId: id) {
                return .success(updated.toDomain())
            }
            return .success(remoteFilm.toDomain())
        } catch {
            if let cached = cachedFilm {
                return .success(cached.toDomain())
            }
            return .failure(error)
        }
    }
}
```

### 6.5. Dependencias iOS (SPM)
| Paquete | Uso | Requerido |
|---------|-----|-----------|
| URLSession (nativo) | Networking | Sí |
| Combine (nativo) | Reactive | Sí |
| SwiftData (nativo iOS 17+) | Persistencia local | Sí |
| Swinject | Inyección de dependencias | Opcional |
| Kingfisher | Carga de imágenes | Opcional |

### 6.6. Pasos de Implementación iOS (Subagente Dedicado)
1. Crear proyecto Xcode en la carpeta `iOS/`
2. Configurar estructura de carpetas según §6.2
3. Configurar `ModelContainer` de SwiftData en `@main`
4. Implementar capa Data (DTO, API Service, SwiftData Model, LocalDataSource, Repository)
5. Implementar capa Domain (Model, Repository Protocol)
6. Implementar DI Container
7. Implementar UI (Splash → List → Detail)
8. Configurar LaunchScreen.storyboard
9. Añadir assets (colores, iconos, logo)
10. Implementar tests unitarios y de UI
11. Configurar scheme y targets de testing

---

## 7. Estrategia de Paginación y Búsqueda

### 7.1. Paginación Client-Side

La API SWAPI devuelve las 6 películas en una sola respuesta, por lo que la paginación se implementa enteramente en el cliente.

**Algoritmo:**
```
INPUT: allFilms (6 películas), itemsPerPage (3), currentPage (1-indexed)
OUTPUT: paginatedFilms, totalPages

1. filteredFilms = allFilms.filter(searchQuery) // si hay búsqueda
2. totalPages = ceil(filteredFilms.size / itemsPerPage)
3. startIndex = (currentPage - 1) * itemsPerPage
4. endIndex = min(startIndex + itemsPerPage, filteredFilms.size)
5. paginatedFilms = filteredFilms.subList(startIndex, endIndex)
```

**Configuración:**
- **Items por página:** 3 (resulta en 2 páginas con 6 películas)
- **Página inicial:** 1
- **Ordenamiento:** Por `episode_id` ascendente (I, II, III, IV, V, VI)

### 7.2. Búsqueda Client-Side

**Comportamiento:**
1. El usuario escribe en el SearchBar
2. Se filtra `allFilms` por `title.contains(query, ignoreCase = true)`
3. Se resetea `currentPage` a 1
4. Se recalcula la paginación con los resultados filtrados
5. Si no hay resultados, mostrar estado "Empty"

**Ejemplo:**
```
Query: "empire"
Resultado: ["The Empire Strikes Back"] → 1 página, 1 resultado

Query: "the"
Resultado: ["The Empire Strikes Back", "Return of the Jedi", "The Phantom Menace",
            "Attack of the Clones", "Revenge of the Sith"] → 2 páginas
```

### 7.3. Flujo Combinado (Búsqueda + Paginación)

```
allFilms (6)
    │
    ▼
[Filtro por searchQuery] ──► filteredFilms (0..6)
    │
    ▼
[Ordenar por episodeId]
    │
    ▼
[Paginar: page * itemsPerPage] ──► displayedFilms (0..3)
    │
    ▼
[Emitir UIState.Success(films, page, totalPages)]
```

---

## 8. Definición de Modelos de Datos

### 8.1. DTO (Data Transfer Object) — Capa Data

| Campo | Tipo | JSON Key | Descripción |
|-------|------|----------|-------------|
| `title` | `String` | `title` | Título de la película |
| `episodeId` | `Int` | `episode_id` | Número de episodio |
| `openingCrawl` | `String` | `opening_crawl` | Texto introductorio |
| `director` | `String` | `director` | Director |
| `producer` | `String` | `producer` | Productor(es), separados por coma |
| `releaseDate` | `String` | `release_date` | Fecha YYYY-MM-DD |
| `characters` | `List<String>` | `characters` | URLs de personajes |
| `planets` | `List<String>` | `planets` | URLs de planetas |
| `starships` | `List<String>` | `starships` | URLs de naves |
| `vehicles` | `List<String>` | `vehicles` | URLs de vehículos |
| `species` | `List<String>` | `species` | URLs de especies |
| `url` | `String` | `url` | URL del recurso |
| `created` | `String` | `created` | Timestamp de creación (ignorado) |
| `edited` | `String` | `edited` | Timestamp de edición (ignorado) |

### 8.2. Modelo de Dominio — Capa Domain

| Campo | Tipo | Origen | Descripción |
|-------|------|--------|-------------|
| `id` | `Int` | Extraído de `url` | ID único de la película |
| `title` | `String` | `title` | Título |
| `episodeId` | `Int` | `episode_id` | Número de episodio |
| `openingCrawl` | `String` | `opening_crawl` | Texto introductorio |
| `director` | `String` | `director` | Director |
| `producer` | `String` | `producer` | Productor(es) |
| `releaseDate` | `String` | `release_date` | Fecha de estreno |
| `charactersCount` | `Int` | `characters.size` | Número de personajes |
| `planetsCount` | `Int` | `planets.size` | Número de planetas |
| `starshipsCount` | `Int` | `starships.size` | Número de naves |
| `vehiclesCount` | `Int` | `vehicles.size` | Número de vehículos |
| `speciesCount` | `Int` | `species.size` | Número de especies |

### 8.3. Función de Mapeo DTO → Domain

```kotlin
// Android (Kotlin)
fun FilmDto.toDomain(): Film {
    val id = url.trimEnd('/').split("/").last().toIntOrNull() ?: 0
    return Film(
        id = id,
        title = title,
        episodeId = episodeId,
        openingCrawl = openingCrawl,
        director = director,
        producer = producer,
        releaseDate = releaseDate,
        charactersCount = characters.size,
        planetsCount = planets.size,
        starshipsCount = starships.size,
        vehiclesCount = vehicles.size,
        speciesCount = species.size
    )
}
```

```swift
// iOS (Swift)
extension FilmDTO {
    func toDomain() -> Film {
        let id = url.split(separator: "/").last.flatMap { Int($0) } ?? 0
        return Film(
            id: id,
            title: title,
            episodeId: episodeId,
            openingCrawl: openingCrawl,
            director: director,
            producer: producer,
            releaseDate: releaseDate,
            charactersCount: characters.count,
            planetsCount: planets.count,
            starshipsCount: starships.count,
            vehiclesCount: vehicles.count,
            speciesCount: species.count
        )
    }
}
```

### 8.4. Conversión Episode ID → Numeral Romano

```kotlin
fun Int.toRomanNumeral(): String = when (this) {
    1 -> "I"
    2 -> "II"
    3 -> "III"
    4 -> "IV"
    5 -> "V"
    6 -> "VI"
    else -> this.toString()
}
```

---

## 9. Capa de Persistencia (Offline Support)

### 9.1. Objetivo
Proveer una experiencia de uso offline completa. Los datos de películas obtenidos de la API SWAPI se almacenan localmente, permitiendo que la app funcione sin conexión a internet después de la primera carga exitosa.

### 9.2. Estrategia: Cache-First (Offline-First)

```
┌────────────────────────────────────────────────────────────┐
│                    FLUJO CACHE-FIRST                        │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  1. ViewModel solicita datos al Repository                 │
│          │                                                 │
│          ▼                                                 │
│  2. Repository consulta LOCAL DB (Room / SwiftData)        │
│          │                                                 │
│     ┌────┴────┐                                            │
│     │¿Hay     │                                            │
│     │caché?   │                                            │
│     └────┬────┘                                            │
│      SÍ  │  NO                                             │
│          │  │                                              │
│     ┌────┘  └────┐                                         │
│     │            │                                         │
│     ▼            ▼                                         │
│  3a. Emit      3b. Emit                                    │
│  Success       Loading                                     │
│  (cached)      (spinner)                                   │
│     │            │                                         │
│     ▼            ▼                                         │
│  4. AMBOS: Llamar API SWAPI en background                  │
│          │                                                 │
│     ┌────┴────┐                                            │
│     │¿API OK? │                                            │
│     └────┬────┘                                            │
│      SÍ  │  NO                                             │
│          │  │                                              │
│     ┌────┘  └────────┐                                     │
│     ▼                ▼                                     │
│  5a. Guardar       5b. Si hay caché →                      │
│  en DB local       mantener datos previos                  │
│     │              Si NO hay caché →                       │
│     ▼              Emit Error (retry)                      │
│  6. Emit                                                   │
│  Success                                                   │
│  (fresh data)                                              │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### 9.3. Android — Room Database

#### 9.3.1. Esquema de Base de Datos

**Base de datos:** `star_wars_database`  
**Versión:** 1

**Tabla: `films`**

| Columna | Tipo SQLite | Nullable | Descripción |
|---------|------------|----------|-------------|
| `id` | INTEGER | NO (PK) | ID único extraído de URL de la API |
| `title` | TEXT | NO | Título de la película |
| `episode_id` | INTEGER | NO | Número de episodio (1-6) |
| `opening_crawl` | TEXT | NO | Texto introductorio |
| `director` | TEXT | NO | Director |
| `producer` | TEXT | NO | Productor(es) separados por coma |
| `release_date` | TEXT | NO | Fecha en formato YYYY-MM-DD |
| `characters_count` | INTEGER | NO | Nº de personajes |
| `planets_count` | INTEGER | NO | Nº de planetas |
| `starships_count` | INTEGER | NO | Nº de naves |
| `vehicles_count` | INTEGER | NO | Nº de vehículos |
| `species_count` | INTEGER | NO | Nº de especies |
| `last_updated` | INTEGER | NO | Timestamp (millis) de última actualización |

#### 9.3.2. Operaciones del DAO

| Operación | Método | Retorno | Uso |
|-----------|--------|---------|-----|
| Obtener todos | `getAllFilms()` | `Flow<List<FilmEntity>>` | Listado reactivo |
| Obtener por ID | `getFilmById(id)` | `Flow<FilmEntity?>` | Detalle reactivo |
| Buscar por título | `searchFilms(query)` | `Flow<List<FilmEntity>>` | Búsqueda local |
| Insertar/Actualizar | `insertFilms(films)` | `Unit` | Upsert masivo |
| Insertar uno | `insertFilm(film)` | `Unit` | Upsert individual |
| Borrar todos | `deleteAllFilms()` | `Unit` | Reset de caché |
| Contar films | `getFilmCount()` | `Int` | Verificar caché |
| Última actualización | `getLastUpdateTimestamp()` | `Long?` | Frescura del caché |

#### 9.3.3. Mapeos Entity ↔ Domain

```kotlin
// Entity → Domain
fun FilmEntity.toDomain(): Film = Film(
    id = id,
    title = title,
    episodeId = episodeId,
    openingCrawl = openingCrawl,
    director = director,
    producer = producer,
    releaseDate = releaseDate,
    charactersCount = charactersCount,
    planetsCount = planetsCount,
    starshipsCount = starshipsCount,
    vehiclesCount = vehiclesCount,
    speciesCount = speciesCount
)

// Domain → Entity
fun Film.toEntity(): FilmEntity = FilmEntity(
    id = id,
    title = title,
    episodeId = episodeId,
    openingCrawl = openingCrawl,
    director = director,
    producer = producer,
    releaseDate = releaseDate,
    charactersCount = charactersCount,
    planetsCount = planetsCount,
    starshipsCount = starshipsCount,
    vehiclesCount = vehiclesCount,
    speciesCount = speciesCount
)

// DTO → Entity (directo, sin pasar por Domain)
fun FilmDto.toEntity(): FilmEntity {
    val id = url.trimEnd('/').split("/").last().toIntOrNull() ?: 0
    return FilmEntity(
        id = id,
        title = title,
        episodeId = episodeId,
        openingCrawl = openingCrawl,
        director = director,
        producer = producer,
        releaseDate = releaseDate,
        charactersCount = characters.size,
        planetsCount = planets.size,
        starshipsCount = starships.size,
        vehiclesCount = vehicles.size,
        speciesCount = species.size
    )
}
```

#### 9.3.4. Configuración de Hilt para Room

```kotlin
// DatabaseModule.kt
@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {
    @Provides @Singleton
    fun provideDatabase(@ApplicationContext ctx: Context): StarWarsDatabase =
        Room.databaseBuilder(ctx, StarWarsDatabase::class.java, "star_wars_database").build()

    @Provides @Singleton
    fun provideFilmDao(db: StarWarsDatabase): FilmDao = db.filmDao()
}

// AppModule.kt (actualizado)
@Provides @Singleton
fun provideFilmRepository(api: StarWarsApi, filmDao: FilmDao): FilmRepository =
    FilmRepositoryImpl(api, filmDao)
```

### 9.4. iOS — SwiftData

#### 9.4.1. Características de SwiftData
- Framework nativo de Apple (iOS 17+, macOS 14+)
- Basado en macros de Swift (`@Model`)
- Persistencia automática con SQLite bajo el capó
- Integración nativa con SwiftUI y `@Query`
- Thread-safety a través de actores
- Predicados type-safe con `#Predicate`

#### 9.4.2. Esquema del Modelo

**Modelo: `FilmSwiftDataModel`**

| Propiedad | Tipo Swift | Atributos | Descripción |
|-----------|----------|-----------|-------------|
| `id` | `Int` | `@Attribute(.unique)` | ID único (PK, upsert) |
| `title` | `String` | — | Título de la película |
| `episodeId` | `Int` | — | Número de episodio |
| `openingCrawl` | `String` | — | Texto introductorio |
| `director` | `String` | — | Director |
| `producer` | `String` | — | Productor(es) |
| `releaseDate` | `String` | — | Fecha YYYY-MM-DD |
| `charactersCount` | `Int` | — | Nº de personajes |
| `planetsCount` | `Int` | — | Nº de planetas |
| `starshipsCount` | `Int` | — | Nº de naves |
| `vehiclesCount` | `Int` | — | Nº de vehículos |
| `speciesCount` | `Int` | — | Nº de especies |
| `lastUpdated` | `Date` | — | Fecha de última actualización |

#### 9.4.3. Configuración del ModelContainer

```swift
// StarWarsAppApp.swift
@main
struct StarWarsAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [FilmSwiftDataModel.self])
    }
}
```

- `modelContainer(for:)` configura automáticamente el almacenamiento SQLite
- SwiftData crea y gestiona las migraciones automáticamente para cambios simples
- El `ModelContext` se inyecta automáticamente vía `@Environment(\.modelContext)`

#### 9.4.4. Operaciones del LocalDataSource

| Operación | Método | Retorno | Uso |
|-----------|--------|---------|-----|
| Obtener todos | `fetchAllFilms()` | `[FilmSwiftDataModel]` | Listado |
| Obtener por ID | `fetchFilm(byId:)` | `FilmSwiftDataModel?` | Detalle |
| Guardar | `saveFilms(_:)` | `Void` | Upsert masivo |
| Borrar todos | `deleteAllFilms()` | `Void` | Reset de caché |
| Contar | `getFilmCount()` | `Int` | Verificar caché |

### 9.5. Política de Caché

| Regla | Descripción |
|-------|-------------|
| **Tiempo de expiración** | Sin expiración fija — los datos de Star Wars son estáticos |
| **Estrategia de refresh** | Siempre intentar refresh en background al abrir la app |
| **Prioridad** | Datos locales primero → datos remotos en background |
| **Conflictos** | El dato remoto siempre gana (REPLACE / upsert) |
| **Primer uso** | Sin caché → Loading spinner → API call obligatoria |
| **Borrado de caché** | Solo manual (limpieza de datos de la app) |
| **Tamaño estimado** | ~6 registros × ~2KB = ~12KB (insignificante) |

### 9.6. Beneficios de la Persistencia

1. **Experiencia offline:** El usuario puede ver películas sin conexión
2. **Velocidad percibida:** Los datos aparecen instantáneamente desde la DB local
3. **Reducción de llamadas API:** Solo se llama a la API cuando se quiere refrescar
4. **Resiliencia:** Errores de red no impiden el uso de la app (si hay caché)
5. **Consistencia:** Single Source of Truth (DB local) alimenta al UI

---

## 10. Fases de Implementación

### Fase 1 — Configuración del Proyecto (Android)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 1.1 | Añadir dependencias | Retrofit, Hilt, Navigation, Coroutines, Splash API, Room | ⬜ |
| 1.2 | Configurar plugins Hilt/KSP | build.gradle.kts root y app | ⬜ |
| 1.3 | Crear `StarWarsApplication` | Clase Application con `@HiltAndroidApp` | ⬜ |
| 1.4 | Actualizar `AndroidManifest.xml` | Registrar Application, tema splash, permisos INTERNET | ⬜ |
| 1.5 | Actualizar paleta de colores | Colores temáticos Star Wars | ⬜ |
| 1.6 | Sync Gradle y verificar build | Compilar sin errores | ⬜ |

### Fase 2 — Capa de Datos Remota (Android)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 2.1 | Crear `FilmDto.kt` | DTO con `@SerializedName` y `toDomain()` + `toEntity()` | ⬜ |
| 2.2 | Crear `StarWarsApi.kt` | Interface Retrofit con `getFilms()` y `getFilmById()` | ⬜ |
| 2.3 | Crear `AppModule.kt` | Módulo Hilt: OkHttp, Retrofit, API | ⬜ |
| 2.4 | Verificar llamada API | Test manual/unitario de la capa remota | ⬜ |

### Fase 3 — Capa de Persistencia Local (Android)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 3.1 | Crear `FilmEntity.kt` | Entidad Room con `@Entity`, `@PrimaryKey`, `@ColumnInfo` | ⬜ |
| 3.2 | Crear `FilmDao.kt` | DAO con `@Query`, `@Insert`, operaciones CRUD | ⬜ |
| 3.3 | Crear `StarWarsDatabase.kt` | `@Database` abstract class con `filmDao()` | ⬜ |
| 3.4 | Crear `DatabaseModule.kt` | Módulo Hilt: Room DB, DAOs | ⬜ |
| 3.5 | Crear funciones de mapeo | `FilmEntity.toDomain()`, `Film.toEntity()`, `FilmDto.toEntity()` | ⬜ |
| 3.6 | Verificar persistencia | Test de inserción, lectura y búsqueda local | ⬜ |

### Fase 4 — Capa de Dominio y Repositorio (Android)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 4.1 | Crear `Film.kt` | Modelo de dominio limpio | ⬜ |
| 4.2 | Crear `Resource.kt` | Sealed class: Loading, Success, Error | ⬜ |
| 4.3 | Crear `FilmRepository.kt` | Interface en Domain con `Flow<Resource<T>>` | ⬜ |
| 4.4 | Crear `FilmRepositoryImpl.kt` | Implementación offline-first (API + Room) | ⬜ |
| 4.5 | Crear helper de numerales romanos | Extensión `Int.toRomanNumeral()` | ⬜ |
| 4.6 | Crear helper de formato de fecha | Extensión para formatear `YYYY-MM-DD` a locale | ⬜ |
| 4.7 | Prover repositorio en AppModule | `provideFilmRepository(api, filmDao)` | ⬜ |

### Fase 5 — Navegación (Android)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 5.1 | Crear `Screen.kt` | Sealed class de rutas | ⬜ |
| 5.2 | Crear `NavGraph.kt` | NavHost con Splash, FilmList, FilmDetail | ⬜ |
| 5.3 | Actualizar `MainActivity.kt` | @AndroidEntryPoint, SplashScreen API, NavGraph | ⬜ |

### Fase 6 — Splash Screen (Android)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 6.1 | Configurar tema splash sistema | `Theme.App.Starting` en themes.xml | ⬜ |
| 6.2 | Crear `SplashScreen.kt` | Composable con animación fade-in y delay | ⬜ |
| 6.3 | Crear drawable splash | VectorDrawable del logo Star Wars | ⬜ |

### Fase 7 — Listado de Películas (Android)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 7.1 | Crear `FilmListUiState` | Sealed class: Loading, Success, Error, Empty | ⬜ |
| 7.2 | Crear `FilmListViewModel.kt` | Carga offline-first, búsqueda, paginación client-side | ⬜ |
| 7.3 | Crear `FilmCard.kt` | Card composable con info de película | ⬜ |
| 7.4 | Crear `SearchBar.kt` | Campo de búsqueda con icono y clear | ⬜ |
| 7.5 | Crear `PaginationControls.kt` | Botones anterior/siguiente + indicador | ⬜ |
| 7.6 | Crear `FilmListScreen.kt` | Pantalla completa integrando componentes | ⬜ |
| 7.7 | Verificar listado funcional | Probar carga, scroll, búsqueda, paginación, offline | ⬜ |

### Fase 8 — Detalle de Película (Android)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 8.1 | Crear `FilmDetailUiState` | Sealed class: Loading, Success, Error | ⬜ |
| 8.2 | Crear `FilmDetailViewModel.kt` | Carga offline-first por ID desde SavedStateHandle | ⬜ |
| 8.3 | Crear `FilmDetailScreen.kt` | Layout completo: header, crawl, info, stats | ⬜ |
| 8.4 | Verificar navegación list → detail | Probar ida y vuelta con diferentes películas | ⬜ |
| 8.5 | Verificar detalle offline | Comprobar que funciona sin conexión si hay caché | ⬜ |

### Fase 9 — Componentes Comunes y Pulido (Android)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 9.1 | Crear `LoadingIndicator.kt` | CircularProgress temático | ⬜ |
| 9.2 | Crear `ErrorMessage.kt` | Mensaje de error con retry | ⬜ |
| 9.3 | Refinar tema Material 3 | Dark theme, colores Star Wars, tipografía | ⬜ |
| 9.4 | Pulir animaciones y transiciones | Navegación animada entre pantallas | ⬜ |
| 9.5 | Probar en diferentes tamaños de pantalla | Phone y tablet (responsive) | ⬜ |

### Fase 10 — Testing (Android)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 10.1 | Tests unitarios de `FilmRepositoryImpl` | Mock de API + Mock de DAO, verificar offline-first | ⬜ |
| 10.2 | Tests unitarios de `FilmListViewModel` | Estados, paginación, búsqueda | ⬜ |
| 10.3 | Tests unitarios de `FilmDetailViewModel` | Carga por ID, estados | ⬜ |
| 10.4 | Tests de Room (DAO) | Inserción, lectura, búsqueda, borrado | ⬜ |
| 10.5 | Tests de UI (Compose) | Splash, List, Detail | ⬜ |

---

### Fase 11 — Configuración del Proyecto (iOS) ⚡ EN PARALELO

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 11.1 | Crear proyecto Xcode | Estructura según §6.2, iOS 17+ | ⬜ |
| 11.2 | Configurar `ModelContainer` | SwiftData en `@main` App struct | ⬜ |
| 11.3 | Configurar LaunchScreen | LaunchScreen.storyboard | ⬜ |

### Fase 12 — Capa de Datos (iOS)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 12.1 | Crear `FilmDTO.swift` | Decodable DTO con CodingKeys | ⬜ |
| 12.2 | Crear `StarWarsAPIService.swift` | Networking con URLSession async/await | ⬜ |
| 12.3 | Crear `FilmSwiftDataModel.swift` | Modelo @Model con SwiftData | ⬜ |
| 12.4 | Crear `FilmLocalDataSource.swift` | Actor con CRUD sobre SwiftData | ⬜ |
| 12.5 | Verificar llamada API | Test manual de la capa remota | ⬜ |

### Fase 13 — Capa de Dominio y Repositorio (iOS)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 13.1 | Crear `Film.swift` | Modelo de dominio (Identifiable, Equatable) | ⬜ |
| 13.2 | Crear `FilmRepository.swift` | Protocol del repositorio | ⬜ |
| 13.3 | Crear `FilmRepositoryImpl.swift` | Implementación offline-first (API + SwiftData) | ⬜ |
| 13.4 | Crear funciones de mapeo | `toDomain()`, `toSwiftDataModel()` | ⬜ |
| 13.5 | Crear `DependencyContainer.swift` | Container DI manual o Swinject | ⬜ |

### Fase 14 — Splash y Navegación (iOS)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 14.1 | Crear `SplashView.swift` | Vista de splash con animación SwiftUI | ⬜ |
| 14.2 | Crear `AppRouter.swift` | NavigationStack routing | ⬜ |
| 14.3 | Configurar `ContentView.swift` | Root view con navigation | ⬜ |

### Fase 15 — Listado de Películas (iOS)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 15.1 | Crear `FilmListViewModel.swift` | @MainActor, @Published, paginación y búsqueda | ⬜ |
| 15.2 | Crear `FilmCardView.swift` | Card de película estilo SwiftUI | ⬜ |
| 15.3 | Crear `SearchBarView.swift` | Barra de búsqueda con .searchable | ⬜ |
| 15.4 | Crear `PaginationView.swift` | Controles de paginación | ⬜ |
| 15.5 | Crear `FilmListView.swift` | Vista completa integrando componentes | ⬜ |
| 15.6 | Verificar listado funcional | Probar carga, búsqueda, paginación, offline | ⬜ |

### Fase 16 — Detalle de Película (iOS)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 16.1 | Crear `FilmDetailViewModel.swift` | Carga offline-first por ID | ⬜ |
| 16.2 | Crear `FilmDetailView.swift` | Layout completo: header, crawl, info, stats | ⬜ |
| 16.3 | Verificar navegación list → detail | Probar ida y vuelta | ⬜ |

### Fase 17 — Componentes Comunes y Tema (iOS)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 17.1 | Crear `LoadingView.swift` | ProgressView temático | ⬜ |
| 17.2 | Crear `ErrorView.swift` | Vista de error con retry | ⬜ |
| 17.3 | Crear `StarWarsColors.swift` | Extensión Color con paleta Star Wars | ⬜ |
| 17.4 | Crear `StarWarsFonts.swift` | Fuentes personalizadas | ⬜ |
| 17.5 | Configurar Assets.xcassets | Colores, iconos, logo | ⬜ |
| 17.6 | Pulir animaciones y transiciones | Navegación animada | ⬜ |

### Fase 18 — Testing (iOS)

| # | Tarea | Detalle | Estado |
|---|-------|---------|--------|
| 18.1 | Tests unitarios de `FilmRepositoryImpl` | Mock de API + Mock de LocalDataSource | ⬜ |
| 18.2 | Tests unitarios de `FilmListViewModel` | Estados, paginación, búsqueda | ⬜ |
| 18.3 | Tests unitarios de `FilmDetailViewModel` | Carga por ID, estados | ⬜ |
| 18.4 | Tests de SwiftData | Inserción, lectura, búsqueda | ⬜ |
| 18.5 | Tests de UI (XCUITest) | Flujos de splash, list, detail | ⬜ |

---

## 11. Gestión de Errores y Estados

### 11.1. Estados de UI (Patrón Sealed)

Cada pantalla maneja 3 estados fundamentales:

```
┌──────────┐     success     ┌──────────┐
│          │ ──────────────► │          │
│ Loading  │                 │ Success  │
│          │ ◄────────────── │          │
└────┬─────┘     refresh     └──────────┘
     │
     │ failure
     ▼
┌──────────┐     retry       ┌──────────┐
│          │ ──────────────► │          │
│  Error   │                 │ Loading  │
│          │                 │          │
└──────────┘                 └──────────┘
```

### 11.2. Tipos de Error Manejados

| Error | Causa | Mensaje al Usuario | Acción |
|-------|-------|-------------------|--------|
| `IOException` | Sin conexión a internet | "Sin conexión. Verifica tu red." | Retry |
| `HttpException` | Error HTTP (4xx/5xx) | "Error del servidor. Intenta más tarde." | Retry |
| `JsonSyntaxException` | Respuesta malformada | "Error procesando datos." | Retry |
| `SocketTimeoutException` | Timeout de red | "La conexión tardó demasiado." | Retry |
| `UnknownHostException` | DNS fallido | "No se pudo conectar al servidor." | Retry |
| `Exception` genérica | Otro error no previsto | "Ocurrió un error inesperado." | Retry |

### 11.3. Estado Vacío (Empty State)

Cuando la búsqueda no encuentra resultados:
- Mostrar icono ilustrativo (ej: un droide triste)
- Texto: "No se encontraron películas para '{query}'"
- Sugerencia: "Intenta con otro término de búsqueda"

---

## 12. Testing

### 12.1. Estrategia de Testing Android

| Nivel | Herramientas | Scope | Carpeta |
|-------|-------------|-------|---------|
| **Unit Tests** | JUnit 4 + Mockk + kotlinx-coroutines-test | ViewModels, Repository, Mappers | `test/` |
| **Integration Tests** | JUnit 4 + MockWebServer | API + Repository integrados | `test/` |
| **Database Tests** | JUnit 4 + Room In-Memory DB | DAO operations | `androidTest/` |
| **UI Tests** | Compose Testing + JUnit 4 | Screens, componentes | `androidTest/` |

### 12.2. Tests Unitarios Planificados

#### `FilmDtoMappingTest`
- Verificar que `FilmDto.toDomain()` mapea correctamente todos los campos
- Verificar que `FilmDto.toEntity()` mapea correctamente a Entity
- Verificar extracción del ID desde URL
- Verificar conteo de arrays (characters, planets, etc.)

#### `FilmEntityMappingTest`
- Verificar que `FilmEntity.toDomain()` mapea correctamente
- Verificar que `Film.toEntity()` mapea correctamente
- Verificar round-trip: `DTO → Entity → Domain → Entity`

#### `FilmDaoTest` (Integration, con Room in-memory)
- Verificar `insertFilms()` inserta correctamente
- Verificar `getAllFilms()` retorna Flow con datos ordenados por `episode_id`
- Verificar `getFilmById()` retorna el film correcto
- Verificar `searchFilms()` filtra por título
- Verificar `insertFilms()` con `REPLACE` actualiza registros existentes
- Verificar `deleteAllFilms()` limpia la tabla
- Verificar `getFilmCount()` retorna el conteo correcto
- Verificar `getLastUpdateTimestamp()` retorna el timestamp más reciente

#### `FilmRepositoryImplTest`
- Mock de `StarWarsApi` y `FilmDao`
- Verificar flujo offline-first: emite caché → llama API → actualiza caché → emite datos frescos
- Verificar que si la API falla y hay caché → emite éxito con datos cacheados (no error)
- Verificar que si la API falla y NO hay caché → emite error
- Verificar que `getFilmById()` sigue la misma lógica offline-first
- Verificar que los datos se guardan en la DB después de una llamada API exitosa

#### `FilmListViewModelTest`
- Verificar estado inicial es `Loading`
- Verificar transición a `Success` tras carga exitosa
- Verificar transición a `Error` tras fallo (sin caché)
- Verificar filtrado por búsqueda
- Verificar paginación: página correcta, total de páginas, límites
- Verificar que búsqueda resetea a página 1

#### `FilmDetailViewModelTest`
- Verificar obtención del `filmId` desde `SavedStateHandle`
- Verificar carga exitosa del film
- Verificar estado de error cuando el film no existe

### 12.3. Tests de UI Planificados

#### `SplashScreenTest`
- Verificar que se muestra el logo/texto
- Verificar que navega al listado tras delay

#### `FilmListScreenTest`
- Verificar que se muestra la lista de películas
- Verificar que el SearchBar filtra resultados
- Verificar que la paginación funciona
- Verificar que hacer click en una película navega al detalle
- Verificar que se muestra estado de carga
- Verificar que se muestra estado de error con retry

#### `FilmDetailScreenTest`
- Verificar que se muestran todos los campos
- Verificar que el opening crawl se muestra correctamente
- Verificar que el botón back funciona

### 12.4. Estrategia de Testing iOS

| Nivel | Herramientas | Scope |
|-------|-------------|-------|
| **Unit Tests** | XCTest + async/await | ViewModels, Repository, Mappers |
| **Database Tests** | XCTest + in-memory ModelContainer | SwiftData operations |
| **UI Tests** | XCUITest | Flujos de navegación, interacción |

#### Tests Unitarios iOS Planificados

#### `FilmDTOMappingTests`
- Verificar que `FilmDTO.toDomain()` mapea correctamente
- Verificar que `FilmDTO.toSwiftDataModel()` mapea correctamente
- Verificar decodificación JSON con `CodingKeys`

#### `FilmSwiftDataModelTests` (con ModelContainer in-memory)
- Verificar `saveFilms()` persiste correctamente
- Verificar `fetchAllFilms()` retorna datos ordenados
- Verificar `fetchFilm(byId:)` retorna el film correcto
- Verificar `deleteAllFilms()` limpia el store
- Verificar upsert con `@Attribute(.unique)`

#### `FilmRepositoryImplTests`
- Mock de `StarWarsAPIServiceProtocol` y `FilmLocalDataSource`
- Verificar flujo offline-first equivalente a Android
- Verificar fallback a caché cuando la API falla

#### `FilmListViewModelTests`
- Verificar estados `@Published`
- Verificar paginación y búsqueda client-side

#### `FilmDetailViewModelTests`
- Verificar carga exitosa y estado de error

---

## 13. Recursos y Assets

### 13.1. Iconos y Gráficos

| Recurso | Formato | Uso | Plataforma |
|---------|---------|-----|-----------|
| App Icon | PNG/WebP (mipmap) + SVG (xcassets) | Ícono de la app en launcher | Android + iOS |
| Splash Logo | VectorDrawable + SVG | Logo en pantalla de splash | Android + iOS |
| Film Placeholder | VectorDrawable + SVG | Placeholder si no hay poster | Android + iOS |
| Star Wars Logo | VectorDrawable/PNG + SVG | Header/TopBar | Android + iOS |

### 13.2. Paleta de Colores

| Nombre | Hex | Uso |
|--------|-----|-----|
| Star Wars Yellow | `#FFE81F` | Acentos, títulos, logo |
| Space Black | `#000000` | Fondo principal |
| Dark Space | `#1A1A2E` | Fondo secundario |
| Card Background | `#16213E` | Fondo de cards |
| Light Gray | `#B0B0B0` | Texto secundario |
| Jedi Blue | `#0D47A1` | Acentos positivos |
| Sith Red | `#C62828` | Errores, acentos negativos |
| White | `#FFFFFF` | Texto principal en dark mode |

### 13.3. Tipografía

- **Títulos principales:** Bold, tamaño grande (Star Wars style)
- **Subtítulos:** SemiBold, tamaño medio
- **Body:** Regular, tamaño normal
- **Caption:** Regular, tamaño pequeño, color gris
- **Opening Crawl:** Italic o Regular, color amarillo

### 13.4. Strings (Internacionalización)

```xml
<!-- res/values/strings.xml -->
<string name="app_name">Star Wars App</string>
<string name="splash_title">STAR WARS</string>
<string name="films_title">Star Wars Films</string>
<string name="search_hint">Buscar película...</string>
<string name="film_detail_title">Film Detail</string>
<string name="episode_format">Episode %s</string>
<string name="director_label">Director</string>
<string name="producer_label">Producer</string>
<string name="release_date_label">Release Date</string>
<string name="opening_crawl_label">Opening Crawl</string>
<string name="characters_label">Characters</string>
<string name="planets_label">Planets</string>
<string name="starships_label">Starships</string>
<string name="vehicles_label">Vehicles</string>
<string name="species_label">Species</string>
<string name="page_indicator">Página %1$d de %2$d</string>
<string name="error_no_connection">Sin conexión. Verifica tu red.</string>
<string name="error_server">Error del servidor. Intenta más tarde.</string>
<string name="error_generic">Ocurrió un error inesperado.</string>
<string name="error_no_results">No se encontraron películas para \"%s\"</string>
<string name="retry">Reintentar</string>
<string name="loading">Cargando...</string>
```

---

## 14. Estrategia de Subagentes (Desarrollo Paralelo)

### 14.1. Concepto

El desarrollo de Android e iOS se ejecuta **simultáneamente** mediante el uso de **subagentes especializados**, donde cada agente trabaja de forma independiente sobre su plataforma respectiva, siguiendo la misma especificación funcional definida en este documento.

### 14.2. Arquitectura de Subagentes

```
┌──────────────────────────────────────────────────────────┐
│                    AGENTE ORQUESTADOR                     │
│          (Coordina, planifica, revisa ambos)              │
├───────────────────────┬──────────────────────────────────┤
│                       │                                  │
│   ┌───────────────────┴──────┐  ┌───────────────────────┐│
│   │    SUBAGENTE ANDROID     │  │    SUBAGENTE iOS      ││
│   │                          │  │                        ││
│   │  • Kotlin + Compose      │  │  • Swift + SwiftUI     ││
│   │  • Room (persistencia)   │  │  • SwiftData (persist) ││
│   │  • Hilt (DI)             │  │  • DI Container        ││
│   │  • Retrofit (network)    │  │  • URLSession (network)││
│   │  • Gradle build          │  │  • Xcode build         ││
│   │                          │  │                        ││
│   │  Fases 1-10              │  │  Fases 11-18           ││
│   └──────────────────────────┘  └────────────────────────┘│
│                                                          │
│   ┌──────────────────────────────────────────────────────┐│
│   │              RECURSOS COMPARTIDOS                     ││
│   │  • Especificación funcional (este documento)          ││
│   │  • API SWAPI (mismos endpoints y respuestas)          ││
│   │  • Paleta de colores Star Wars (§13.2)                ││
│   │  • Diseño de pantallas (§4)                           ││
│   │  • Arquitectura Clean + MVVM (§3)                     ││
│   │  • Estrategia de persistencia offline-first (§9)      ││
│   └──────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────┘
```

### 14.3. Roles y Responsabilidades

| Rol | Responsabilidad | Plataformas |
|-----|----------------|-------------|
| **Agente Orquestador** | Coordinar, planificar, resolver conflictos, revisar entregables | Ambas |
| **Subagente Android** | Implementar fases 1-10 (Android nativo Kotlin/Compose) | Android |
| **Subagente iOS** | Implementar fases 11-18 (iOS nativo Swift/SwiftUI) | iOS |

### 14.4. Instrucciones para Subagentes

#### 14.4.1. Subagente Android
```
Contexto: Proyecto Star Wars App nativo para Android.
Workspace: d:\Star-Wars-Demo-APP\android\
Especificación: Sección §5 de PLANIFICACION.md
Persistencia: Room Database (Sección §9.3)
Fases: 1 a 10 (secuencial dentro de Android)

Prioridad:
1. Configurar dependencias y build
2. Capa de datos remota (Retrofit)
3. Capa de persistencia local (Room)
4. Capa de dominio y repositorio offline-first  
5. Navegación y splash
6. UI de listado (con paginación y búsqueda)
7. UI de detalle
8. Componentes comunes y pulido
9. Testing
```

#### 14.4.2. Subagente iOS
```
Contexto: Proyecto Star Wars App nativo para iOS.
Workspace: d:\Star-Wars-Demo-APP\iOS\
Especificación: Sección §6 de PLANIFICACION.md
Persistencia: SwiftData (Sección §9.4)
Fases: 11 a 18 (secuencial dentro de iOS)

Prioridad:
1. Crear proyecto Xcode con estructura y ModelContainer
2. Capa de datos remota (URLSession)
3. Capa de persistencia local (SwiftData)
4. Capa de dominio y repositorio offline-first
5. Navegación y splash
6. UI de listado (con paginación y búsqueda)
7. UI de detalle
8. Componentes comunes, tema y testing
```

### 14.5. Paralelismo y Dependencias

```
Tiempo ──────────────────────────────────────────────────────►

Android:  [F1: Config] → [F2: Remote] → [F3: Room] → [F4: Domain] → [F5-6: Nav+Splash] → [F7: List] → [F8: Detail] → [F9: Polish] → [F10: Test]
                                                                           │
iOS:      [F11: Config] → [F12: Data] → [F13: Domain] → [F14: Nav+Splash] → [F15: List] → [F16: Detail] → [F17: Polish] → [F18: Test]
                                                                           │
                                                                  ▲ ambos en paralelo ▲
```

- **Sin dependencias entre plataformas:** Android y iOS no dependen el uno del otro
- **Especificación compartida:** Ambos siguen la misma especificación funcional
- **Resultado idéntico:** Ambas apps deben tener la misma funcionalidad y UX equivalente
- **Ejecución:** Los subagentes pueden trabajar completamente en paralelo

### 14.6. Criterios de Aceptación por Subagente

**Android completado cuando:**
- ✅ Compila sin errores con `./gradlew assembleDebug`
- ✅ Splash → Lista → Detalle funcional
- ✅ Paginación y búsqueda client-side funcionando
- ✅ Persistencia Room con estrategia offline-first
- ✅ Tests unitarios pasan
- ✅ Funciona en API 28+

**iOS completado cuando:**
- ✅ Compila sin errores en Xcode
- ✅ Splash → Lista → Detalle funcional
- ✅ Paginación y búsqueda client-side funcionando
- ✅ Persistencia SwiftData con estrategia offline-first
- ✅ Tests unitarios pasan
- ✅ Funciona en iOS 17+

---

## 15. Checklist de Entregables

### Android (Activo)

- [ ] Proyecto compila sin errores con todas las dependencias
- [ ] Splash Screen funcional con animación
- [ ] Listado de películas cargado desde SWAPI
- [ ] Búsqueda client-side por título funcional
- [ ] Paginación client-side funcional (3 items/página)
- [ ] Navegación a detalle de película funcional
- [ ] Pantalla de detalle con toda la información
- [ ] **Persistencia Room:** Base de datos local con tabla `films`
- [ ] **Offline-first:** Datos cacheados disponibles sin conexión
- [ ] **Cache-first:** Datos locales se muestran primero, API actualiza en background
- [ ] Manejo de estados: Loading, Error (con retry), Success, Empty
- [ ] Tema visual Star Wars aplicado (colores, tipografía)
- [ ] Código organizado en Clean Architecture
- [ ] Inyección de dependencias con Hilt funcional
- [ ] Tests unitarios para ViewModels, Repository y DAO
- [ ] Tests de UI para pantallas principales
- [ ] Sin warnings críticos ni errores de lint
- [ ] Funciona correctamente en API 28+

### iOS (Activo)

- [ ] Proyecto Xcode creado con estructura correcta
- [ ] Capa Data implementada (DTO, API, Repository)
- [ ] Capa Domain implementada (Model, Protocol)
- [ ] **Persistencia SwiftData:** Modelo @Model con almacenamiento local
- [ ] **Offline-first:** Datos cacheados disponibles sin conexión
- [ ] **Cache-first:** Datos locales se muestran primero, API actualiza en background
- [ ] Container de DI configurado
- [ ] SplashView implementada con animación
- [ ] FilmListView implementada con búsqueda y paginación
- [ ] FilmDetailView implementada con información completa
- [ ] NavigationStack configurado
- [ ] Tema visual Star Wars aplicado
- [ ] Tests unitarios y de UI
- [ ] Funciona correctamente en iOS 17+

---

> **Nota final:** Este documento es el plan maestro de desarrollo. Las fases de Android (1-10) y las de iOS (11-18) se ejecutan **en paralelo** mediante subagentes dedicados. Cada subagente sigue las secciones relevantes de este documento como especificación única y compartida. La persistencia offline-first garantiza una experiencia de usuario fluida incluso sin conectividad.

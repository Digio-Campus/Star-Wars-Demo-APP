# ⭐ Star Wars Demo APP

A native cross-platform demonstration application for **iOS** and **Android** that showcases a modern mobile development approach using the Star Wars public API ([SWAPI](https://swapi.info)).

**By Jose Valero** | *Status: Active Development*

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Installation & Setup](#installation--setup)
- [Development](#development)
- [API Integration](#api-integration)
- [Database & Caching](#database--caching)

---

## 🌟 Overview

Star Wars Demo APP is a native mobile application developed in parallel for both iOS and Android platforms. It demonstrates best practices in mobile development including:

- **Clean Architecture with MVVM** pattern
- **Modern UI frameworks** (Jetpack Compose for Android, SwiftUI for iOS)
- **Responsive async/await patterns** (Coroutines on Android, async/await on iOS)
- **Offline-first strategy** with local caching
- **Type-safe dependency injection** (Hilt for Android, Swift DI for iOS)

---

## ✨ Features

- ✅ **Splash Screen** — Themed welcome screen with Star Wars branding
- ✅ **Movies Listing** — Paginated list of all Star Wars films
- ✅ **Search Functionality** — Filter movies by title in real-time
- ✅ **Movie Details** — Comprehensive information for each film
- ✅ **Offline Support** — Local caching with cache-first strategy
- ✅ **Material Design 3** (Android) / **Liquid Glass UI** (iOS 17+)
- ✅ **Responsive Error Handling** — Graceful failure management

---

## 🛠️ Tech Stack

### Android
| Component | Technology | Version |
|-----------|-----------|---------|
| **Language** | Kotlin | 2.0.21 |
| **UI Framework** | Jetpack Compose | Material 3 |
| **Architecture** | MVVM + Clean Architecture | — |
| **Networking** | Retrofit + OkHttp | Latest |
| **Serialization** | Gson | — |
| **Async** | Coroutines + Flow | — |
| **DI** | Hilt (Dagger) | — |
| **Navigation** | Navigation Compose | — |
| **Database** | Room (SQLite) | — |
| **Min SDK** | API 28 (Android 9.0) | — |
| **Target SDK** | API 36 (Android 15) | — |
| **Build Tool** | Gradle (Kotlin DSL) | AGP 8.13.2 |

### iOS
| Component | Technology | Version |
|-----------|-----------|---------|
| **Language** | Swift | Latest |
| **UI Framework** | SwiftUI | iOS 17+ |
| **Architecture** | MVVM + Clean Architecture | — |
| **Networking** | URLSession (native) | — |
| **Async** | async/await + Combine | — |
| **DI** | Swift DI / Swinject | — |
| **Navigation** | NavigationStack | — |
| **Database** | SwiftData (Core Data) | — |
| **Minimum OS** | iOS 17 | — |
| **Build Tool** | Xcode + SPM | — |

---

## 📁 Project Structure

```
Star-Wars-Demo-APP/
├── android/                    # Android application
│   ├── app/
│   │   ├── src/
│   │   │   ├── main/          # Main application source
│   │   │   ├── androidTest/   # Instrumented tests
│   │   │   └── test/          # Unit tests
│   │   └── build.gradle.kts
│   ├── gradle/                # Gradle wrapper configuration
│   └── settings.gradle.kts
│
├── iOS/                       # iOS application
│   └── Star-Wars-Demo-APP/
│       ├── Star-Wars-Demo-APP/
│       │   ├── Data/          # Data layer
│       │   ├── Domain/        # Domain layer
│       │   ├── UI/            # Presentation layer
│       │   ├── DI/            # Dependency injection
│       │   └── Assets.xcassets/
│       ├── Star-Wars-Demo-APP.xcodeproj/
│       └── README.md
│
├── PLANIFICACION.md           # Full development plan & specifications
└── README.md                  # This file
```

---

## 🏗️ Architecture

Both platforms implement a **Clean Architecture pattern** with **MVVM** presentation layer:

### Layer Structure

```
┌─────────────────────────────────────┐
│   Presentation Layer (MVVM)         │
│   ├─ Views / ViewModels             │
│   └─ State Management               │
├─────────────────────────────────────┤
│   Domain Layer                      │
│   ├─ Entities                       │
│   ├─ Use Cases                      │
│   └─ Repository Interfaces          │
├─────────────────────────────────────┤
│   Data Layer                        │
│   ├─ Repository Implementations     │
│   ├─ Remote Data Sources (API)      │
│   ├─ Local Data Sources (DB)        │
│   └─ Models/Mappers                 │
└─────────────────────────────────────┘
```

### Key Design Patterns

- **Repository Pattern** — Abstraction over data sources
- **Dependency Injection** — Loose coupling between layers
- **State Management** — Reactive programming (Flow/Combine)
- **Cache-First Strategy** — Load local data first, sync in background

---

## 🚀 Installation & Setup

### Android Setup

#### Prerequisites
- Android Studio (latest)
- JDK 11+
- Android SDK 36

#### Steps
```bash
cd android
./gradlew build                    # Build the project
./gradlew installDebug             # Install debug APK to device/emulator
```

**Configuration:**
- Package: `com.dam.starwarsapp`
- Min SDK: 28
- Target SDK: 36

### iOS Setup

#### Prerequisites
- Xcode 15+
- Swift 5.10+
- iOS 17.0+

#### Steps
```bash
cd iOS/Star-Wars-Demo-APP
xcodebuild build                   # Build the project
# Or open in Xcode:
open Star-Wars-Demo-APP.xcodeproj
```

**Configuration:**
- Minimum Deployment: iOS 17
- Device Support: iPhone only

---

## 🔧 Development

### Project Configuration

The project uses **Gradle Version Catalog** (Android) for centralized dependency management:
- See `android/gradle/libs.versions.toml` for dependency versions

### Build Variants

**Android:**
- `debug` — Debug build with verbose logging
- `release` — Optimized release build with ProGuard

**iOS:**
- `Debug` — Development build
- `Release` — App Store build

---

## 🌐 API Integration

### SWAPI (Star Wars API)

**Base URL:** `https://swapi.info/api`

#### Endpoints Used

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/films` | Retrieve all Star Wars movies (6 films) |
| `GET` | `/films/{id}` | Get detailed information for a specific film |

#### Response Model (Film)
```json
{
  "title": "A New Hope",
  "episode_id": 4,
  "opening_crawl": "It is a period of civil war...",
  "director": "George Lucas",
  "producer": "Gary Kurtz, Rick McCallum",
  "release_date": "1977-05-25",
  "characters": ["url1", "url2", ...],
  "planets": ["url1", "url2", ...],
  "starships": ["url1", "url2", ...],
  "vehicles": ["url1", "url2", ...],
  "species": ["url1", "url2", ...],
  "created": "2014-12-10T14:23:09.256453Z",
  "edited": "2014-12-20T21:17:50.345571Z",
  "url": "https://swapi.info/api/films/1/"
}
```

**Note:** SWAPI returns all films in a single response. Pagination is handled client-side.

---

## 💾 Database & Caching

### Offline-First Strategy

The application implements a **cache-first** approach:

1. **Load Local Data** — Fetch from local database first
2. **Display Immediately** — Show cached data to user
3. **Sync in Background** — Fetch fresh data from API
4. **Update if Changed** — Replace cache if new data differs

### Storage

**Android:**
- **Room Database** — SQLite wrapper for type-safe database access
- **Persistence:** Automatic on app install
- **Schema:** Films, Characters, Planets, Starships, Species

**iOS:**
- **SwiftData** — Modern Core Data wrapper (iOS 17+)
- **Persistence:** Automatic on app install
- **Models:** 
  - `FilmSwiftDataModel`
  - `PersonSwiftDataModel`
  - `PlanetSwiftDataModel`
  - `StarshipSwiftDataModel`

---

## 📱 Screenshots & UI

- **Splash Screen** — Star Wars themed welcome
- **Movies List** — Paginated grid/list view
- **Search** — Real-time filtering
- **Movie Details** — Full film information with related data

---

## ✅ Development Checklist

- [x] Project setup & configuration
- [x] Architecture design
- [x] API integration
- [x] Local caching setup
- [x] UI implementation
- [ ] Unit & Integration tests
- [ ] Performance optimization
- [ ] Release builds

For detailed development plan, see [PLANIFICACION.md](PLANIFICACION.md).

---

## 📜 License

This project is created for educational and demonstration purposes.

**By Jose Valero** | 2026
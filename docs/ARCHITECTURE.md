# HabitFlow Mobile — Architecture Guide

## 1. Architectural Pattern: Feature-First Clean Architecture

HabitFlow Mobile follows a strict **Feature-First Clean Architecture** governed by **SOLID** principles and **Dart 3** strong typing.

```text
lib/
├── main.dart
└── src/
    ├── app.dart
    ├── core/
    │   ├── constants/
    │   ├── errors/
    │   ├── network/
    │   ├── theme/
    │   ├── utils/
    │   └── widgets/
    └── features/
        ├── auth/
        │   ├── domain/
        │   │   ├── entities/
        │   │   ├── enums/
        │   │   ├── models/
        │   │   ├── repositories/
        │   │   └── states/
        │   ├── data/
        │   │   └── repositories/
        │   └── presentation/
        │       ├── controllers/
        │       ├── providers/
        │       ├── screens/
        │       └── widgets/
        └── habits/
            ├── domain/
            │   ├── entities/
            │   ├── models/
            │   ├── repositories/
            │   ├── states/
            │   └── usecases/
            ├── data/
            │   ├── models/
            │   └── repositories/
            └── presentation/
                ├── controllers/
                ├── providers/
                ├── screens/
                └── widgets/
```

---

## 2. Layer Responsibilities & Dependency Rule

Dependencies always point **inward** toward the `domain` layer:

```text
Presentation  --->  Domain  <---  Data
```

### 2.1 Domain Layer (`features/<feature>/domain/`)
* **Pure Dart only**: Must NEVER import `package:flutter/material.dart` (except pure value types if strictly unavoidable, though avoided here) and must **NEVER** import `package:supabase_flutter/supabase_flutter.dart` or any infrastructure SDK.
* **`entities/`**: Immutable domain objects (`AppUser`, `Habit`, `HabitLog`) with value equality (`==` and `hashCode`).
* **`enums/`**: Domain enumerations (`AuthFormMode`), one per file.
* **`models/`**: Dart 3 `typedef` Records and immutable value containers (`HabitWithMetrics`, `DashboardKpiSummary`, `DailyProgressPoint`, `DashboardFilterState`, `HabitsWorkspaceData`, `HabitFormPayload`, `ToggleActionResult`, `SignUpResult`).
* **`states/`**: Dart 3 `sealed class` state hierarchies (`AuthSessionState`, `AuthSubmissionState`, `DashboardUiState`) enabling exhaustive `switch` pattern matching.
* **`repositories/`**: Abstract interfaces (`abstract interface class AuthRepository`, `abstract interface class HabitRepository`).
* **`usecases/`**: Pure, deterministic business logic services (`BuildDashboardUiStateUseCase`).

### 2.2 Data Layer (`features/<feature>/data/`)
* **`models/`**: Data Transfer Objects (`HabitDto`, `HabitLogDto`) responsible exclusively for JSON serialization (`fromJson`, `toInsertJson`, `toUpdateJson`).
* **`repositories/`**: Concrete implementations of domain repository interfaces:
  * `SupabaseAuthRepository` & `SupabaseHabitRepository`: Communicate with Supabase GoTrue and PostgreSQL tables (`public.habits`, `public.habit_logs`) under Row Level Security (RLS).
  * `LocalDemoAuthRepository` & `LocalDemoHabitRepository`: In-memory implementations adhering to the **Liskov Substitution Principle (LSP)** when environment credentials are not configured.

### 2.3 Presentation Layer (`features/<feature>/presentation/`)
* **`controllers/`**: Riverpod 2.x `Notifier` and `AsyncNotifier` classes (`AuthSessionNotifier`, `AuthSubmissionController`, `DashboardFilterNotifier`, `HabitsController`).
* **`providers/`**: Dependency injection wiring and derived state providers (`auth_providers.dart`, `habits_providers.dart`).
* **`screens/`**: Top-level page scaffolds (`AuthScreen`, `DashboardScreen`).
* **`widgets/`**: Atomic, single-responsibility, reusable UI components (one public widget class per file).

### 2.4 Core Layer (`core/`)
* **`constants/`**: Application constants (`AppConstants`) and environment configuration (`EnvConfig`).
* **`errors/`**: Pure `AppException` sealed hierarchy (`app_exception.dart`) and infrastructure error translator (`SupabaseErrorMapper`).
* **`network/`**: Infrastructure provider (`supabaseClientProvider`) restricted exclusively to `data/repositories/`.
* **`theme/`**: Material 3 design tokens (`AppColors`), light/dark themes (`AppTheme`), and reactive theme persistence (`ThemeModeNotifier`).
* **`utils/`**: Deterministic date calculations (`HabitDateUtils`), streak calculation engine (`StreakCalculator`), and input sanitization/validation (`Validators`).


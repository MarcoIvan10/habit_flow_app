# HabitFlow Mobile — Coding Standards (Clean Code & SOLID)

All human developers and AI coding agents working on this repository must strictly adhere to the rules below.

---

## 1. One Public Type / One Responsibility Per File (SRP)

Every file in `lib/src/` must have a **single, well-defined responsibility**:

* **Never** place an `enum` inside the same file as a `class` or `sealed class`.
* **Never** combine multiple independent `typedef` Records or data models in a single file.
* **Never** define private helper `StatelessWidget` or `StatefulWidget` classes (`_MySubWidget`) inside a screen or parent widget file. Extract every sub-widget into its own dedicated file under `presentation/widgets/`.
* **Never** mix Riverpod dependency injection providers (`Provider`), state controllers (`Notifier` / `AsyncNotifier`), and domain business calculations in a single file.

---

## 2. Documentation & Commenting Rules

### 2.1 Mandatory English Header & Member Documentation (`///`)
* Every file, class, interface, sealed class, enum, typedef record, method, constructor, and field **must** have a clear, accurate **English** DartDoc comment (`///`) explaining what it does, its parameters, and its return value.

### 2.2 Zero Inline Comments Inside Method Bodies (`//`)
* **Strict Rule**: Do **NOT** write inline comments (`// ...`) inside method bodies.
* Code inside methods must be self-documenting through:
  * Descriptive variable and parameter names in English.
  * Small, focused private helper methods whose names explain the intent.

---

## 3. SOLID Principles Enforcement

* **S — Single Responsibility Principle**: Each class, use case, notifier, DTO, and widget has only one reason to change.
* **O — Open/Closed Principle**: Behavior (such as authentication or habit persistence) can be extended with new implementations without modifying consumers.
* **L — Liskov Substitution Principle**: `SupabaseHabitRepository` and `LocalDemoHabitRepository` honor the exact contract of `HabitRepository`; `SupabaseAuthRepository` and `LocalDemoAuthRepository` honor the exact contract of `AuthRepository`.
* **I — Interface Segregation Principle**: Repository interfaces expose only cohesive domain operations.
* **D — Dependency Inversion Principle**: Presentation and domain layers depend exclusively on abstract interfaces (`AuthRepository`, `HabitRepository`), never on `SupabaseClient` or DTO classes.

---

## 4. Dart 3 Modern Type System

* **Sealed Classes for UI & Domain States**:
  Never use loose boolean flags (`isLoading`, `hasError`, `isSuccess`) to model state. Always use `sealed class` hierarchies (`AuthSessionState`, `AuthSubmissionState`, `DashboardUiState`, `AppException`) and consume them with exhaustive `switch` expressions.
* **Records for Value Tuples**:
  Use immutable Dart 3 `typedef` Records (`WeekDayInfo`, `StreakMetrics`, `HabitWithMetrics`, `DashboardKpiSummary`, `DailyProgressPoint`) for lightweight composite values.
* **Immutability**:
  Mark domain entities and value objects with `final class` and `const` constructors.


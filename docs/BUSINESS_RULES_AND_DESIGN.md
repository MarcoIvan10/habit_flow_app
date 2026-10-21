# HabitFlow Mobile — Business Rules & Design System

## 1. Core Business Rules

### 1.1 Weekly Calendar Window (`HabitDateUtils`)
* Weeks always start on **Monday (`weekday == 1`)** and end on **Sunday (`weekday == 7`)** in the user's local timezone.
* All persistence and streak comparisons use canonical ISO date strings (`YYYY-MM-DD`) truncated to local midnight (`00:00:00`) to avoid UTC offset drift.
* Future dates (`day.isFuture == true`) cannot be marked as completed in the UI or database.

### 1.2 Streak Calculation Engine (`StreakCalculator`)
Given a set of completed ISO dates (`Set<String>`) for a habit and a reference `today`:
1. **Current Active Streak (`currentStreak`)**:
   * If `today` is completed, count consecutive completed days backward starting from `today`.
   * If `today` is **not** yet completed, but `yesterday` **is** completed, the streak remains alive: count consecutive completed days backward starting from `yesterday`.
   * Otherwise, `currentStreak` is `0`.
2. **Historical Best Streak (`bestStreak`)**:
   * Sort all unique completed dates in ascending order and compute the longest sequence of consecutive calendar days ($\Delta = 1\text{ day}$).

### 1.3 Dashboard KPI Formulas (`BuildDashboardUiStateUseCase`)
1. **Active Habits**: Total count of user habits and count of unique categories across those habits.
2. **Today's Completion**:
   $$\text{Today Rate} = \frac{\text{Habits completed on todayIso}}{\text{Total active habits}}$$
3. **Top Active Streak**: Maximum `currentStreak` among all active habits and the name of the leading habit.
4. **Weekly Effectiveness**:
   $$\text{Weekly Rate} = \frac{\text{Completed check-ins in selected week across filtered habits}}{\text{Filtered habits count} \times 7}$$

### 1.4 Optimistic UI & Celebration Rule (`HabitsController`)
* Toggling a day (`Lun`–`Dom`) mutates the local state **immediately** (`0ms` perceived latency), recalculating streaks, KPIs, and `fl_chart` bars synchronously.
* If the background repository request fails, the state automatically rolls back to the snapshot prior to the tap and surfaces a user-friendly error message.
* If a toggle action marks a habit as completed for **today** (`isoDate == todayIso`) and causes **all** active habits to be completed today ($100\%$), the confetti celebration triggers.

---

## 2. Design System & UI Specifications

### 2.1 Color Palette (`AppColors`)
Inspired by modern SaaS interfaces (Tailwind Slate + Indigo + Emerald):
* **Primary Brand**: Indigo (`#6366F1` / `#4F46E5`)
* **Success / Full Completion**: Emerald (`#10B981` / `#059669`)
* **Streak / Warning**: Amber (`#F59E0B`)
* **Danger / Error**: Rose (`#F43F5E`)
* **Additional Habit Accents**: Cyan (`#06B6D4`), Purple (`#A855F7`)
* **Surfaces**:
  * Light Mode: Scaffold `Slate 50` (`#F8FAFC`), Cards `White` (`#FFFFFF`), Border `Slate 200` (`#E2E8F0`)
  * Dark Mode: Scaffold `Slate 950` (`#020617`), Cards `Slate 900` (`#0F172A`), Border `Slate 800` (`#1E293B`)

### 2.2 Typography & Components
* **Font Family**: `Inter` via `google_fonts`.
* **Cards**: `16px` border radius, `0` elevation, `1px` subtle border.
* **Charts (`fl_chart`)**:
  * **Weekly Daily Progress (`BarChart`)**: Bars display `0%–100%` daily completion; bars at `100%` render in `Emerald 500`, partial progress renders in `Indigo 500`.
  * **Streaks Comparison (`BarChart`)**: Grouped bars comparing `currentStreak` (`Amber 500`) vs `bestStreak` (`Indigo 500`) per habit.


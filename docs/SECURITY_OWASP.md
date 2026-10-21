# HabitFlow Mobile — Security & OWASP Compliance Guide

This document defines the mandatory security architecture and controls enforced across HabitFlow Mobile, aligned with the **OWASP Top 10 (Web/API)** and **OWASP Mobile Top 10**.

---

## 1. OWASP A01: Broken Access Control & IDOR Prevention

### 1.1 Row Level Security (RLS) in PostgreSQL
All tables in the `public` schema (`public.habits` and `public.habit_logs`) enforce mandatory PostgreSQL Row Level Security:
* Every query (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) is restricted at the database engine level to `auth.uid() = user_id`.
* **Cross-Tenant IDOR Protection on Foreign Keys**:
  In `public.habit_logs`, checking `auth.uid() = user_id` alone is insufficient if an attacker supplies their own `user_id` alongside another user's `habit_id` UUID. Therefore, the RLS policy on `public.habit_logs` enforces an explicit ownership check against `public.habits`:
  ```sql
  using (
    auth.uid() = user_id
    and exists (
      select 1 from public.habits h
      where h.id = habit_logs.habit_id
        and h.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.habits h
      where h.id = habit_logs.habit_id
        and h.user_id = auth.uid()
    )
  );
  ```

### 1.2 Client-Side Defense-in-Depth
Even though PostgreSQL RLS is the authoritative security boundary, `SupabaseHabitRepository` explicitly scopes every `.select()`, `.update()`, and `.delete()` query with `.eq('user_id', userId)` after verifying an active authenticated session via `_requireAuthenticatedUserId()`.

---

## 2. OWASP M1 / A02: Improper Credential Usage & Secret Management

* **Zero Hardcoded Credentials**: No Supabase URLs, JWT keys, or secret tokens may ever be hardcoded as fallback constants inside Dart source files (`lib/`).
* **Environment Injection**:
  * Local development reads `.env` (which is strictly ignored in `.gitignore`).
  * Production/Release builds support `--dart-define-from-file=.env` or `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.
* **Safe Error Translation**:
  `SupabaseErrorMapper` translates low-level `AuthException` and `PostgrestException` errors into user-friendly `AppException` instances. Raw database error codes, SQL table names, and stack traces are never rendered in the UI.

---

## 3. OWASP A03: Injection & Input Validation

Validation is enforced both at the **Client Domain Layer** and the **Database Schema Layer**:

1. **Client Sanitizers (`Validators`)**:
   * Control characters (`\x00-\x1F`, `\x7F`) are stripped and consecutive whitespace is normalized before any repository call.
   * Habit names are constrained between `2` and `60` characters.
   * Emails are validated against a strict format expression and normalized to lowercase.
   * Passwords require a minimum of `8` characters and alphanumeric composition on sign-up.
2. **PostgreSQL Schema Constraints (`supabase/schema.sql`)**:
   * `name`: `check (char_length(trim(name)) between 2 and 60)`
   * `category`: Allowlist check `check (category in ('Salud', 'Deporte', 'Mente', 'Productividad', 'Finanzas'))`
   * `color`: Allowlist check `check (color in ('indigo', 'emerald', 'amber', 'rose', 'cyan', 'purple'))`
   * `icon`: Length check `check (char_length(icon) between 1 and 16)`
   * `completed_date`: Prevents arbitrary future date tampering `check (completed_date <= (current_date + 1))`

---

## 4. OWASP A04 / API4: Unrestricted Resource Consumption, DDoS & Race Conditions

1. **In-Flight Mutation Guard (`_inFlightToggleKeys`)**:
   Rapid repeated taps on the same habit day button (`habitId:isoDate`) are blocked while a request for that key is already in flight. This prevents race conditions in Optimistic UI and protects the Supabase PostgREST endpoint from accidental request floods (Application-Layer self-DDoS).
2. **Authentication Cooldown**:
   `AuthSubmissionController` prevents concurrent duplicate form submissions while a request is in progress and enforces a brief cooldown window after consecutive failures.
3. **Bounded Queries**:
   `SupabaseHabitRepository.fetchHabitLogs()` applies a defensive row limit (`.limit(2000)`) and indexed ordering so memory and bandwidth consumption remain bounded over multi-year usage.

---

## 5. OWASP Mobile M9 / A05: Insecure Data Storage & Platform Hardening

* `android/app/src/main/AndroidManifest.xml` explicitly sets:
  * `android:allowBackup="false"`
  * `android:fullBackupContent="false"`
  This prevents unauthorized extraction of local `SharedPreferences` and session artifacts via `adb backup`.


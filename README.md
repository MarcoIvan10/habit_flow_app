# HabitFlow Mobile

Personal mobile application built with **Flutter (Dart 3)**, **Riverpod 2.x**, **Supabase (PostgreSQL + GoTrue + RLS)**, and **fl_chart** for daily habit tracking, deterministic streak calculation, and weekly visual analytics.

---

## Documentation (`docs/`)

All architectural decisions, coding standards, OWASP security controls, business rules, and instructions for human developers or AI agents are documented in the [`docs/`](docs/) directory:

1. **[Architecture Guide](docs/ARCHITECTURE.md)** — Feature-First Clean Architecture, layer boundaries, and dependency inversion rules.
2. **[Coding Standards (Clean Code & SOLID)](docs/CODING_STANDARDS.md)** — Single-concept-per-file rule, English DartDoc headers (`///`), zero inline method comments, and Dart 3 patterns.
3. **[Security & OWASP Compliance](docs/SECURITY_OWASP.md)** — Row Level Security (RLS), anti-IDOR foreign key verification, secret management, input sanitization, and anti-DDoS concurrency guards.
4. **[Business Rules & Design System](docs/BUSINESS_RULES_AND_DESIGN.md)** — Streak calculation rules, Monday–Sunday week math, KPI formulas, Optimistic UI, and Material 3 theme tokens.
5. **[AI Agent Guidelines](docs/AI_AGENT_GUIDELINES.md)** — Mandatory operational checklist for AI coding assistants and contributors.

---

## Getting Started

### 1. Database Setup (Supabase)
Execute the SQL script located at [`supabase/schema.sql`](supabase/schema.sql) in your Supabase SQL Editor to provision the `habits` and `habit_logs` tables, indexes, constraints, and Row Level Security (RLS) policies.

### 2. Environment Variables
Copy [`.env.example`](.env.example) to `.env` (ignored by Git) and provide your Supabase project credentials:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key
```

### 3. Run & Test

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

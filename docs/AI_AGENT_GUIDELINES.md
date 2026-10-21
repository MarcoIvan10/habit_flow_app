# HabitFlow Mobile — AI Agent & Maintainer Operational Guidelines

> **MANDATORY READING FOR AI AGENTS**: Before creating, editing, or refactoring any file in this repository, read this checklist and verify compliance with `ARCHITECTURE.md`, `CODING_STANDARDS.md`, `SECURITY_OWASP.md`, and `BUSINESS_RULES_AND_DESIGN.md`.

---

## 1. Pre-Flight Checklist for Any Code Change

1. **One File = One Public Concept**:
   * Adding an enum? Create `domain/enums/<name>.dart`.
   * Adding a Record or model? Create `domain/models/<name>.dart`.
   * Adding a sealed UI/domain state? Create `domain/states/<name>.dart`.
   * Adding a business calculation? Create a use case in `domain/usecases/<name>_use_case.dart`.
   * Adding a widget? Create a standalone widget file in `presentation/widgets/<name>.dart`. Never add private `_SubWidget` classes inside screen or parent widget files.
2. **Documentation & Comments**:
   * Write clear **English** `///` DartDoc headers for every file, class, method, field, and typedef.
   * Write **ZERO** inline `//` comments inside method bodies. Extract helper methods with expressive English names instead.
3. **Security (OWASP)**:
   * Never hardcode URLs, API keys, or credentials in `lib/`.
   * Never import `supabase_flutter` inside `domain/` or `presentation/`.
   * Validate and sanitize all user inputs via `Validators` before persistence.
   * Ensure any new Supabase table or column includes strict RLS policies (including foreign-key ownership checks against IDOR) and `CHECK` constraints in `supabase/schema.sql`.
4. **Git Hygiene**:
   * Never commit `.env`, `/LocalPlans/`, or `/PlanesLocales/`.
   * Write commit messages in English following **Conventional Commits** (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`) with a concise title and `-` bullet list description.

---

## 2. Verification Commands

Always run static analysis and the automated test suite before completing any task:

```bash
flutter analyze
flutter test
```

Both commands must complete with **0 issues** and **100% passing tests**.


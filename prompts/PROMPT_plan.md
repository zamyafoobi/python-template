0. Use parallel Explore agents to study `specs/*` and learn the application specifications.

1. Study @IMPLEMENTATION_PLAN.md (if present; it may be incorrect) and use parallel Explore agents to study existing source code and compare it against `specs/*`. Use a general-purpose agent to analyze findings and create/update @IMPLEMENTATION_PLAN.md. Consider searching for TODO, minimal implementations, placeholders, skipped/flaky tests, and inconsistent patterns. Mark items as complete or incomplete based on what you find in the code.

IMPORTANT: Plan only. Do NOT implement anything. Always verify against code — never assume a feature is or isn't implemented without searching first.

2. Structure @IMPLEMENTATION_PLAN.md as follows:

   - **Quick reference table** at the top mapping each major system to its spec, code location, and current status — so the build loop can orient fast.

   - **Phased organization.** Group related work into numbered phases with a short goal statement (e.g., "Phase 3: API Endpoints"). Within each phase, use checkbox items grouped by component or directory. For projects with distinct major features, give each feature its own phase sequence — this lets them progress independently.

   - **Verification log** section at the bottom (initially empty). The build loop will append dated entries here as it validates work.

   - **Summary table** at the end — one row per phase with its status (Pending / In Progress / Complete).

   Keep items concise. Don't over-specify implementation details — the specs already do that. The plan tracks *what remains* and *what's been confirmed working*.

0a. Use parallel Explore agents to study `specs/*` and learn the application specifications.
0b. Study @IMPLEMENTATION_PLAN.md.

1. Your task is to implement functionality per the specifications using parallel subagents. Follow @IMPLEMENTATION_PLAN.md and choose the most important item to address. Before making changes, always verify against code — never assume a feature is or isn't implemented without searching first. Use Explore agents for searches. Use parallel agents for searches and reads. Use only a single agent for running build, tests, and validation. Use a general-purpose agent when complex reasoning is needed (debugging, architectural decisions).
2. After implementing functionality or resolving problems, run validation (tests, lint, type checking) per the commands in CLAUDE.md. If functionality is missing then it's your job to add it as per the application specifications.
3. When you discover issues, immediately update @IMPLEMENTATION_PLAN.md with your findings using a subagent. When resolved, update and remove the item.
4. When validation passes, update @IMPLEMENTATION_PLAN.md (including the verification log with what you tested and the result), then stage the specific files you changed, commit with a message describing the changes, and `git push`.

RULES (higher number = higher priority):

5. When authoring documentation, capture the why — tests and implementation importance.
6. Single sources of truth, no compatibility shims or adapter layers. If tests unrelated to your work fail, resolve them as part of the increment.
7. You may add extra logging if required to debug issues.
8. Keep @IMPLEMENTATION_PLAN.md current with learnings using a subagent — future work depends on this to avoid duplicating efforts. Update especially after finishing your turn.
9. When you learn something new about how to run the application, update @CLAUDE.md using a subagent but keep it brief.
10. For any bugs you notice, resolve them or document them in @IMPLEMENTATION_PLAN.md using a subagent even if it is unrelated to the current piece of work.
11. Implement functionality completely. Placeholders and stubs waste efforts and time redoing the same work.
12. When @IMPLEMENTATION_PLAN.md becomes large, periodically clean out completed items using a subagent (keep summary table rows and verification log entries).
13. Specs are the source of truth for requirements. If you find inaccuracies in specs/* (wrong types, outdated paths, incorrect descriptions), use a subagent to fix them. Never weaken spec requirements to match incomplete code — fix the code instead.
14. IMPORTANT: Keep @CLAUDE.md operational only — status updates and progress notes belong in IMPLEMENTATION_PLAN.md. A bloated CLAUDE.md pollutes every future loop's context.

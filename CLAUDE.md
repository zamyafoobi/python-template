# Project Agent Guidelines

Guidelines for AI agents working on this codebase.

## Specifications

**IMPORTANT:** Before implementing any feature, consult the specifications in `specs/README.md`.

- **Always verify against code.** Never assume a feature is or isn't implemented without searching the codebase first. Specs describe intent; code describes reality.
- **Specs are the source of truth for requirements.** When implementing a feature, follow the design patterns, types, and architecture defined in the relevant spec. Only update a spec to fix inaccuracies (wrong types, outdated paths), never to weaken requirements to match incomplete code.
- **Spec index:** `specs/README.md` lists all specifications organized by category.

## Commands

<!-- TODO: Fill in when tooling is configured.
- **Build:** `<build command>`
- **Test:** `<test command>`
- **Lint:** `<lint command>`
- **Type check:** `<typecheck command>`
-->

**Not yet configured.** When commands are added here, the build loop will use them for validation.

## Architecture

This project uses a **uv workspace monorepo**. Code is split into small, focused Python packages under `packages/`, each with its own `pyproject.toml`. A root `pyproject.toml` declares the workspace members.

### Workspace rules

- **One concern per package.** Each package should own a single domain (e.g., `core`, `server-api`, `server-db`, `cli`). If a module doesn't clearly belong to an existing package, create a new one.
- **Explicit dependencies.** Packages declare dependencies on sibling packages in their own `pyproject.toml` as path dependencies. Never import from a sibling package without declaring the dependency.
- **`-core` packages are leaf dependencies.** Packages named `*-core` contain shared types, errors, and interfaces with minimal external dependencies. They should never depend on non-core siblings.
- **Dependency direction flows inward.** High-level packages (CLI, server, API) depend on lower-level packages (core, db), never the reverse. No circular dependencies.
- **Each package is independently importable.** Every package must have a working `pyproject.toml` and be installable on its own (with its declared dependencies).

### Adding a new package

1. Create `packages/<name>/pyproject.toml` and `packages/<name>/src/<import_name>/`.
2. Add the package path to the root `pyproject.toml` workspace members list.
3. Declare any sibling dependencies as path dependencies in the new package's `pyproject.toml`.
4. Run `uv sync` to update the workspace lockfile.

## Code Style

<!-- Add project-specific conventions. Examples:

- **Formatting:** Tool and config used
- **Naming:** snake_case for functions/variables, PascalCase for types
- **Imports:** Grouping conventions
- **Error handling:** Strategy (error types, propagation)
- **Logging:** Framework and conventions
- **READABILITY:** All code should emphasize readability. If this means more code, that's OK.
-->

## Database

<!-- If the project uses a database, document migration workflow. Examples:

- **Migrations location:** `migrations/` or `src/db/migrations/`
- **Run migrations:** `<migration command>`
- **Create migration:** `<create migration command>`
- **Convention:** `NNN_description.sql` (sequential numbering)
-->

## Local Testing

<!-- Document how to run the project locally for manual verification. Examples:

- **Run server:** `<run command>`
- **Dev mode:** `<dev mode flags or env vars>`
- **Test against local:** `curl http://localhost:<port>/health`
-->

## Troubleshooting

<!-- Document common issues and debugging approaches. Examples:

- **View logs:** `<log command>`
- **Common errors:** List known failure modes and fixes
- **Debug flags:** Environment variables or settings for verbose output
-->

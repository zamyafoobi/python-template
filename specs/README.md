# Specifications

Design specifications for this project. Specs are the source of truth for
requirements -- the planning and build loops read these to determine what to
implement. Specs describe intended design; always check the actual codebase for
current implementation status.

## How to Use Specs

- **Before implementing:** Read the relevant spec to understand the intended design.
- **Always verify against code.** Never assume a feature is or isn't implemented without searching first. Specs describe intent; code describes reality.
- **Creating a new spec:** Copy `_template.md` and fill in the sections.

<!-- Organize specs by category. Each category gets a heading and a table
     with columns: Spec | Code | Purpose.

     The "Code" column links to the source directory or module that implements
     the spec, so agents can navigate from requirements to implementation.

     Example structure (paths follow the uv workspace layout in CLAUDE.md):

## Core

| Spec | Code | Purpose |
|------|------|---------|
| [state-machine.md](./state-machine.md) | [packages/core/src/collector_core/](../packages/core/src/collector_core/) | Agent state machine for conversation flow |
| [error-handling.md](./error-handling.md) | [packages/core/src/collector_core/](../packages/core/src/collector_core/) | Error types and propagation strategy |

## API

| Spec | Code | Purpose |
|------|------|---------|
| [api-routes.md](./api-routes.md) | [packages/server-api/src/collector_server_api/](../packages/server-api/src/collector_server_api/) | REST API routes and schemas |
| [health-check.md](./health-check.md) | [packages/server-api/src/collector_server_api/](../packages/server-api/src/collector_server_api/) | Health endpoint |

     Subdirectories can organize specs for repeated patterns (e.g., collectors,
     integrations, plugins). Add a separate heading and table for each.
-->

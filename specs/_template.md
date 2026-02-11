# [Feature Name]

## Overview

What this feature does and why it exists. Keep it to a few sentences.

### Architecture

How it fits into the system. Include an ASCII diagram if the feature involves
multiple components or a data flow.

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Component A │────>│  Component B │────>│  Component C │
└─────────────┘     └──────────────┘     └─────────────┘
```

## Core Types

Key data structures, models, or interfaces. Include actual type definitions
with file path references so agents can find the implementation.

```python
# packages/<name>/src/<import_name>/types.py
@dataclass
class ExampleType:
    id: str
    name: str
    status: Status
```

| Type | Location | Purpose |
|------|----------|---------|
| `ExampleType` | `packages/<name>/src/<import_name>/types.py` | Core domain entity |

## Behavior

How the feature works at runtime. Cover the main paths:

### Happy Path

1. Step one
2. Step two
3. Step three

### Error Handling

What happens when things go wrong. Which errors are recoverable, which are not.

## Interface

Public API, CLI commands, endpoints, or function signatures exposed by this
feature.

## Configuration

Environment variables, settings, or constants. Use a table:

| Setting | Default | Description |
|---------|---------|-------------|
| `EXAMPLE_SETTING` | `value` | What it controls |

## Dependencies

Other specs, libraries, or services required.

## Design Decisions

Key choices and their rationale. Documenting *why* prevents future agents from
re-evaluating settled decisions.

1. **[Decision]:** Why this approach was chosen over alternatives.
2. **[Decision]:** Trade-offs considered.

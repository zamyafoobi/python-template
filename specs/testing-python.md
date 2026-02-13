# Testing Strategy

## Overview

This document describes a testing philosophy centered on **property-based testing** to ensure correctness
across the full input space, complemented by targeted unit and integration tests for specific
scenarios and edge cases.

### Core Principles

1. **Property-Based Testing First**: Prefer property tests that verify invariants over example-based
   tests that check specific cases
2. **Document Every Test**: Each test MUST include documentation explaining why it's important and
   what invariant it verifies
3. **Structured Logging**: All production code uses structured logging for observability
4. **Fail Fast, Fail Clearly**: Tests should produce clear error messages that identify the root
   cause

## Test Categories

### Unit Tests (Per-Module)

Standard test functions for isolated logic testing. Located in test modules alongside source files
or in a `tests/` directory using `pytest`.

### Property-Based Tests (Hypothesis)

Generative tests that verify invariants hold across randomly generated inputs. Use the `@given`
decorator from the `hypothesis` library.

### Integration Tests

Async tests using `pytest` with `pytest-asyncio` that exercise complete workflows including I/O
operations.

## Property-Based Testing with Hypothesis

### Why Property Tests Over Example-Based

| Example-Based Tests             | Property-Based Tests               |
| ------------------------------- | ---------------------------------- |
| Test specific inputs            | Test input _space_                 |
| May miss edge cases             | Explores edge cases automatically  |
| Documents behavior for one case | Documents invariants for all cases |
| Brittle to refactoring          | Robust to implementation changes   |

Property tests are preferred because they:

1. **Discover edge cases** you didn't think of (unicode, empty strings, boundary values)
2. **Verify invariants** that must hold for all valid inputs
3. **Shrink failures** to minimal reproducible examples
4. **Scale testing** to thousands of cases with one test

### Generators and Strategies

Hypothesis provides strategies for generating test data:

```python
from hypothesis import given
from hypothesis.strategies import (
    text, integers, floats, none, lists, frozensets, from_regex, one_of,
)

@given(
    # String matching regex pattern
    name=from_regex(r"[a-zA-Z][a-zA-Z0-9_]{0,30}", fullmatch=True),
    # Optional value
    max_tokens=none() | integers(min_value=1, max_value=10000),
    # Range of values
    temperature=floats(min_value=0.0, max_value=2.0, allow_nan=False),
    # Collection with size bounds
    items=lists(from_regex(r"[a-z]{1,10}", fullmatch=True), max_size=10),
    # Frozen set (unique values)
    unique_names=frozensets(from_regex(r"[a-z]{1,10}", fullmatch=True), max_size=5),
)
def test_example_property(name, max_tokens, temperature, items, unique_names):
    # Test body using generated values
    assert len(name) <= 31
```

**Common strategies:**

- `from_regex(r"[a-zA-Z0-9]{n,m}", fullmatch=True)` - Regex-based string generation
- `none() | strategy` - Optional values
- `lists(strategy, max_size=n)` - List generation
- `frozensets(strategy, max_size=n)` - Unique value sets
- `integers(min_value=n, max_value=m)` - Numeric ranges
- `floats(min_value=n, max_value=m)` - Float ranges

### Preconditions with assume

Use `assume()` to filter invalid test cases:

```python
from hypothesis import given, assume
from hypothesis.strategies import from_regex

@given(
    prefix=from_regex(r"[a-z]{5,20}", fullmatch=True),
    target=from_regex(r"[A-Z]{5,15}", fullmatch=True),
    suffix=from_regex(r"[a-z]{5,20}", fullmatch=True),
)
def test_deletion(prefix, target, suffix):
    # Skip cases where prefix/suffix contain target
    assume(target not in prefix)
    assume(target not in suffix)

    # Test proceeds only with valid combinations
```

## Key Test Areas

### 1. State Machine Transitions

State machine tests verify correct transitions between states:

- `WaitingForInput` -> `Processing` -> `Responding`
- `Responding` -> `ExecutingAction` -> `Processing` (with results)
- Error recovery: `Error` -> `Processing` (via retry)
- Shutdown: Any state -> `ShuttingDown`

**Key property tests:**

- `test_initial_state_invariant` - Always starts in the correct initial state
- `test_input_always_triggers_processing` - Input deterministically triggers processing
- `test_retry_count_bounded_by_max` - Retry count never exceeds configured maximum
- `test_shutdown_always_succeeds` - Shutdown always works from any state

### 2. Operation Correctness

Property tests for operations verify:

- **Reversibility**: `edit(old->new)` followed by `edit(new->old)` restores original
- **Accuracy**: Reported counts match actual values
- **Idempotency**: Same operation applied twice produces same result
- **Unicode safety**: Multi-byte UTF-8 sequences handled correctly
- **Completeness**: All occurrences processed when expected
- **Isolation**: Non-targeted regions unchanged

### 3. Serialization Roundtrips

Tests verify JSON serialization/deserialization consistency:

```python
import json
from dataclasses import dataclass, asdict
from hypothesis import given
from hypothesis.strategies import from_regex, none, integers, one_of

@given(
    model=from_regex(r"[a-z]{1,20}", fullmatch=True),
    max_tokens=none() | integers(min_value=1, max_value=10000),
)
def test_serialization_roundtrip_preserves_data(model, max_tokens):
    request = {"model": model, "max_tokens": max_tokens}
    serialized = json.dumps(request)
    deserialized = json.loads(serialized)

    assert request["model"] == deserialized["model"]
    assert request["max_tokens"] == deserialized["max_tokens"]
```

### 4. SSE Parsing (Stream Tests)

Tests for Server-Sent Events parsing in streaming responses:

- `test_parse_text_delta_event` - Text content deltas parsed correctly
- `test_parse_action_start` - Action initiation tracked
- `test_parse_message_stop` - Stream completion produces a response

### 5. Retry Behavior

Tests verify retry logic invariants:

- `test_non_retryable_error_fails_immediately` - No retries for 4xx errors
- `test_retryable_error_retries_up_to_max_attempts` - Correct retry count
- Exponential backoff calculations
- Jitter application

## Test Documentation Requirements

**Every test MUST document:**

1. **Purpose**: Why this test is important
2. **Invariant**: What property/behavior it verifies
3. **Context**: When this matters (failure scenarios, edge cases)

### Required Format

```python
def test_example():
    """Brief description of what's being tested.

    Why this is important:
        Explain the significance and potential failure modes this test
        catches. Include real-world scenarios.

    Invariant:
        Formal statement of the property being verified.
        Use mathematical notation if helpful (e.g., for all inputs: P(x) -> Q(x))
    """
    ...
```

### Example

```python
@given(max_retries=integers(min_value=1, max_value=5))
def test_retry_count_bounded_by_max_retries(max_retries):
    """Property test: Retry count never exceeds max_retries.

    Why this is important:
        This property verifies the retry bound invariant:
        - After max_retries errors, the system must stop retrying
        - The system should transition to waiting for input at the limit

        Prevents infinite retry loops that could exhaust resources.

    Invariant:
        retry_count <= max_retries, and state == WaitingForInput
        after max_retries consecutive failures.
    """
    system = create_test_system(max_retries=max_retries)
    for _ in range(max_retries + 5):
        system.inject_error()

    assert system.state == "waiting_for_input"
    assert system.retry_count <= max_retries
```

## Mock Implementations

### Mock Client for System Tests

Used in tests to simulate external service behavior without network calls:

```python
from unittest.mock import AsyncMock

class MockClient:
    async def complete(self, request):
        return Response(
            message="mock response",
            actions=[],
            usage=Usage(),
            finish_reason="stop",
        )

    async def complete_streaming(self, request):
        # Return stream that immediately completes
        async def empty_stream():
            return
            yield  # makes this an async generator
        return empty_stream()
```

### Mock Action for Registry Tests

Used to test action registration and lookup:

```python
class MockAction:
    def __init__(self, name: str):
        self.name = name

    @property
    def description(self) -> str:
        return "A mock action for testing"

    @property
    def input_schema(self) -> dict:
        return {"type": "object", "properties": {}}

    async def invoke(self, args: dict, ctx: ActionContext) -> dict:
        return {"result": "ok"}
```

### Mock Error for Retry Tests

Used to test retry behavior with controllable retryability:

```python
class MockError(Exception):
    def __init__(self, retryable: bool):
        self.retryable = retryable

    @property
    def is_retryable(self) -> bool:
        return self.retryable
```

## Async Testing

### pytest-asyncio

For async tests, use the `@pytest.mark.asyncio` decorator:

```python
import pytest

@pytest.mark.asyncio
async def test_file_editing():
    workspace = setup_workspace()
    editor = FileEditor()

    result = await editor.invoke(
        {"path": "test.txt", "edits": [...]},
        ctx=ActionContext(workspace),
    )

    assert result["edits_applied"] == 1
```

### Running Hypothesis with async code

Hypothesis doesn't natively support async test functions. Wrap async code with an event loop:

```python
import asyncio
from hypothesis import given
from hypothesis.strategies import from_regex

@given(input_text=from_regex(r"[a-z]{1,20}", fullmatch=True))
def test_async_property(input_text):
    async def _inner():
        result = await async_operation(input_text)
        assert result is not None

    asyncio.run(_inner())
```

**Important**: The async inner function must be run to completion inside each test case.

## Running Tests

### All Tests

```bash
pytest
```

### Specific Module

```bash
pytest tests/test_core.py
pytest tests/test_actions.py
pytest tests/test_http.py
```

### Test Filtering

```bash
# Run tests matching pattern
pytest -k state_machine

# Run specific test
pytest -k test_input_transitions_to_processing

# Run tests in specific file
pytest tests/test_agent.py

# Run with output displayed
pytest -s

# Run tests marked as slow
pytest -m slow
```

### Hypothesis Configuration

Control Hypothesis behavior with settings or profiles:

```python
from hypothesis import settings, HealthCheck

# In conftest.py or at module level
settings.register_profile("ci", max_examples=1000)
settings.register_profile("dev", max_examples=50)
settings.register_profile("debug", max_examples=10, verbosity=Verbosity.verbose)

# Activate via command line:
# pytest --hypothesis-seed=12345
# HYPOTHESIS_PROFILE=ci pytest
```

Or per-test:

```python
from hypothesis import given, settings
from hypothesis.strategies import text

@settings(max_examples=500)
@given(name=text(min_size=1))
def test_thorough_check(name):
    ...
```

## Test Helpers

### Workspace Setup

Use `tempfile` for isolated filesystem tests:

```python
import tempfile
from pathlib import Path

def setup_workspace() -> Path:
    tmpdir = tempfile.mkdtemp()
    return Path(tmpdir)
```

### Test System Creation

Helper functions for creating systems with default or custom configs:

```python
def create_test_system(max_retries=3, **overrides):
    config = {
        "max_retries": max_retries,
        **overrides,
    }
    client = MockClient()
    actions = []
    return System(config=config, client=client, actions=actions)
```

### Response Builders

Helpers for constructing mock responses:

```python
def create_simple_response(content: str) -> Response:
    return Response(
        message=content,
        actions=[],
        usage=Usage(),
        finish_reason="stop",
    )

def create_response_with_actions(actions: list) -> Response:
    return Response(
        message="",
        actions=actions,
        usage=Usage(),
        finish_reason="action_use",
    )
```

## Test Dependencies

Add to `requirements-dev.txt` or `pyproject.toml` under dev dependencies:

```
hypothesis>=6.0
pytest>=8.0
pytest-asyncio>=0.23
```

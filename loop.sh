#!/usr/bin/env bash
# Ralph Loop runner.
#
# Usage:
#   ./loop.sh              # Build mode, unlimited iterations
#   ./loop.sh 20           # Build mode, max 20 iterations
#   ./loop.sh plan         # Plan mode, unlimited iterations
#   ./loop.sh plan 5       # Plan mode, max 5 iterations

set -euo pipefail

MODE="build"
MAX_ITERATIONS=0

# Parse arguments
case "${1:-}" in
  plan)
    MODE="plan"
    MAX_ITERATIONS="${2:-0}"
    ;;
  [0-9]*)
    MAX_ITERATIONS="$1"
    ;;
esac

if [ "$MODE" = "plan" ]; then
  PROMPT_FILE="prompts/PROMPT_plan.md"
else
  PROMPT_FILE="prompts/PROMPT_build.md"
fi

ITERATION=0

while true; do
  ITERATION=$((ITERATION + 1))

  if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$ITERATION" -gt "$MAX_ITERATIONS" ]; then
    echo "Reached max iterations ($MAX_ITERATIONS). Stopping."
    break
  fi

  echo "=== Loop iteration $ITERATION (mode: $MODE) ==="

  # Each iteration gets a fresh context window.
  # claude -p reads the prompt from stdin and loads CLAUDE.md automatically.
  if ! claude -p < "$PROMPT_FILE"; then
    echo "claude exited with error on iteration $ITERATION. Stopping."
    exit 1
  fi
done

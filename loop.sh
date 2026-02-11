#!/usr/bin/env bash
# Ralph Loop runner.
#
# Usage:
#   ./loop.sh              # Unlimited iterations
#   ./loop.sh 20           # Max 20 iterations

set -euo pipefail

MAX_ITERATIONS="${1:-0}"
ITERATION=0

while true; do
  ITERATION=$((ITERATION + 1))

  if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$ITERATION" -gt "$MAX_ITERATIONS" ]; then
    echo "Reached max iterations ($MAX_ITERATIONS). Stopping."
    break
  fi

  echo "=== Loop iteration $ITERATION ==="

  # Each iteration gets a fresh context window.
  # claude -p reads the prompt from stdin and loads CLAUDE.md automatically.
  if ! claude -p < prompts/PROMPT_build.md; then
    echo "claude exited with error on iteration $ITERATION. Stopping."
    exit 1
  fi
done

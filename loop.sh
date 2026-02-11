#!/usr/bin/env bash
# Loop runner for autonomous Claude Code agents.
#
# Usage:
#   ./loop.sh                    # Unlimited iterations, opus model
#   ./loop.sh 20                 # Max 20 iterations, opus model
#   ./loop.sh 20 sonnet          # Max 20 iterations, sonnet model
#
# Environment variables:
#   LOOP_COOLDOWN_SECONDS  Minimum seconds between iterations (default: 600 = 10 minutes)

set -euo pipefail

PROMPT_FILE="prompts/PROMPT_build.md"
MAX_ITERATIONS="${1:-0}"
MODEL="${2:-opus}"
ITERATION=0
COOLDOWN_SECONDS="${LOOP_COOLDOWN_SECONDS:-600}"

CONSECUTIVE_FAILURES=0
MAX_CONSECUTIVE_FAILURES=5
FAILURE_BACKOFF_BASE=30

# --- Logging ----------------------------------------------------------------

LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/loop-$(date +%Y-%m-%d-%H%M%S).log"

# Tee all stdout and stderr to the log file while preserving terminal output.
exec > >(tee -a "$LOG_FILE") 2>&1

timestamp() { date +"%Y-%m-%d %H:%M:%S"; }
log() { echo "[$(timestamp)] $*"; }

# --- Signal handling ---------------------------------------------------------

cleanup() {
  log "Signal received. Interrupted during iteration $ITERATION. Exiting."
  exit 130
}
trap cleanup SIGINT SIGTERM

# --- Pre-flight checks -------------------------------------------------------

# Verify prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
  log "Error: $PROMPT_FILE not found."
  exit 1
fi

# Git state sanity check
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  log "Error: not inside a git repository."
  exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
if [ -n "$(git status --porcelain)" ]; then
  log "Error: working tree is not clean on branch '$CURRENT_BRANCH'."
  log "Uncommitted changes:"
  git status --short
  log "Commit or stash changes before running the loop."
  exit 1
fi

log "Git: branch '$CURRENT_BRANCH', working tree clean."

# --- Banner ------------------------------------------------------------------

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Prompt:   $PROMPT_FILE"
echo "Model:    $MODEL"
echo "Cooldown: ${COOLDOWN_SECONDS}s between iterations"
echo "Log:      $LOG_FILE"
[ "$MAX_ITERATIONS" -gt 0 ] && echo "Max:      $MAX_ITERATIONS iterations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# --- Main loop ---------------------------------------------------------------

while true; do
  ITERATION=$((ITERATION + 1))

  if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$ITERATION" -gt "$MAX_ITERATIONS" ]; then
    log "Reached max iterations ($MAX_ITERATIONS). Stopping."
    break
  fi

  log "=== Loop iteration $ITERATION ==="

  ITER_START=$(date +%s)

  # Each iteration gets a fresh context window.
  # claude -p reads the prompt from stdin and loads CLAUDE.md automatically.
  if ! claude -p --model "$MODEL" --dangerously-skip-permissions < "$PROMPT_FILE"; then
    CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
    log "claude exited with error on iteration $ITERATION (failure $CONSECUTIVE_FAILURES/$MAX_CONSECUTIVE_FAILURES)."

    if [ "$CONSECUTIVE_FAILURES" -ge "$MAX_CONSECUTIVE_FAILURES" ]; then
      log "$MAX_CONSECUTIVE_FAILURES consecutive failures. Stopping."
      exit 1
    fi

    # Exponential backoff: 30s, 60s, 120s, 240s
    BACKOFF=$(( FAILURE_BACKOFF_BASE * (2 ** (CONSECUTIVE_FAILURES - 1)) ))
    log "Backing off ${BACKOFF}s before retry..."
    sleep "$BACKOFF"
    continue
  fi

  # Reset failure counter on success
  CONSECUTIVE_FAILURES=0

  if [ -f .build-complete ]; then
    log "All items complete on iteration $ITERATION. Stopping."
    rm -f .build-complete
    exit 0
  fi

  log "Iteration $ITERATION completed."

  # Enforce cooldown before next iteration
  ELAPSED=$(( $(date +%s) - ITER_START ))
  REMAINING=$(( COOLDOWN_SECONDS - ELAPSED ))
  if [ "$REMAINING" -gt 0 ] && { [ "$MAX_ITERATIONS" -eq 0 ] || [ "$ITERATION" -lt "$MAX_ITERATIONS" ]; }; then
    log "Cooldown: waiting ${REMAINING}s before next iteration..."
    sleep "$REMAINING"
  fi
done

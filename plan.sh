#!/usr/bin/env bash
# Single-shot planning: studies specs and code, creates/updates IMPLEMENTATION_PLAN.md.
#
# Usage:
#   ./plan.sh

set -euo pipefail

claude -p < prompts/PROMPT_plan.md

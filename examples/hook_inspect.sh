#!/usr/bin/env bash
# Example hook: Inspect and log messages before/after sending to LLM
# Usage: Set in config.yaml:
#   before_chat_hook: /path/to/hook_inspect.sh
#   after_chat_hook: /path/to/hook_inspect.sh

set -e

# Read JSON from stdin
input=$(cat)

# Parse the stage
stage=$(echo "$input" | jq -r '.stage')

# Log to stderr (won't interfere with JSON output)
echo "=== HOOK TRIGGERED: $stage ===" >&2
echo "$input" | jq -C '.' >&2
echo "" >&2

# Output the unmodified JSON back to stdout
echo "$input"

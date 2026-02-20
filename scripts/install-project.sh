#!/bin/bash
# install-project.sh — Symlink selected agents into a specific project
#
# Usage:
#   bash path/to/scripts/install-project.sh ~/my-project                          # Install ALL agents
#   bash path/to/scripts/install-project.sh ~/my-project orchestrator python-developer test-engineer  # Install specific agents
#
# Project-level agents take priority over global agents.
# To override a global agent, create .claude/agents/<name>.md in the project directly.
# Works from any location — auto-detects where this repo is.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -z "$1" ]; then
  echo "Usage: $0 <project-path> [agent-names...]"
  echo ""
  echo "Examples:"
  echo "  $0 ~/my-project                                    # Install all agents"
  echo "  $0 ~/my-project orchestrator python-developer       # Install specific agents"
  echo ""
  echo "Available agents:"
  find "$AGENTS_DIR/agents" -name "*.md" -exec basename {} .md \; | sort
  exit 1
fi

PROJECT="$1"; shift

echo "=== Project Agent Installation ==="
echo "Project: $PROJECT"
echo ""

mkdir -p "$PROJECT/.claude/agents"

if [ $# -gt 0 ]; then
  # Install specific agents
  for name in "$@"; do
    found=$(find "$AGENTS_DIR/agents" -name "$name.md" 2>/dev/null | head -1)
    if [ -n "$found" ]; then
      ln -sf "$found" "$PROJECT/.claude/agents/$(basename $found)"
      echo "  + $name.md"
    else
      echo "  ! Agent not found: $name"
    fi
  done
else
  # Install all agents
  count=0
  for dir in leadership architecture development quality operations specialist; do
    if [ -d "$AGENTS_DIR/agents/$dir" ]; then
      for agent in "$AGENTS_DIR/agents/$dir"/*.md; do
        [ -f "$agent" ] || continue
        ln -sf "$agent" "$PROJECT/.claude/agents/$(basename $agent)"
        echo "  + $(basename $agent)"
        count=$((count + 1))
      done
    fi
  done
  echo ""
  echo "Installed $count agents"
fi

echo ""
echo "Verify: ls -la $PROJECT/.claude/agents/"

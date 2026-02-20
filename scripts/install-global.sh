#!/bin/bash
# install-global.sh — Symlink all agents and rules into ~/.claude/ for global access
#
# Usage: bash path/to/scripts/install-global.sh
#
# This makes all agents available in every Claude Code session.
# Projects can override by placing a same-named .md in their .claude/agents/
# Works from any location — auto-detects where this repo is.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "=== Agent System Global Installation ==="
echo "Source: $AGENTS_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

# Create target dirs
mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/rules"

# Symlink agents (flattened from subdirectories)
agent_count=0
for dir in leadership architecture development quality operations specialist; do
  if [ -d "$AGENTS_DIR/agents/$dir" ]; then
    for agent in "$AGENTS_DIR/agents/$dir"/*.md; do
      [ -f "$agent" ] || continue
      name=$(basename "$agent")
      ln -sf "$agent" "$CLAUDE_DIR/agents/$name"
      echo "  + agents/$name -> agents/$dir/$name"
      agent_count=$((agent_count + 1))
    done
  fi
done

# Symlink rules
rule_count=0
for rule in "$AGENTS_DIR/rules"/*.md; do
  [ -f "$rule" ] || continue
  name=$(basename "$rule")
  ln -sf "$rule" "$CLAUDE_DIR/rules/$name"
  echo "  + rules/$name"
  rule_count=$((rule_count + 1))
done

echo ""
echo "=== Installation Complete ==="
echo "Agents installed: $agent_count"
echo "Rules installed:  $rule_count"
echo ""
echo "Verify: ls -la $CLAUDE_DIR/agents/"
echo "Verify: ls -la $CLAUDE_DIR/rules/"

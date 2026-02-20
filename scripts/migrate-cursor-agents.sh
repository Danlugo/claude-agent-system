#!/bin/bash
# migrate-cursor-agents.sh — Convert Cursor agents to Claude Code format
#
# Usage:
#   bash path/to/scripts/migrate-cursor-agents.sh ~/my-project
#
# What it does:
#   1. Scans .cursor/agents/*.md in the project
#   2. Converts them to Claude Code format (adds YAML frontmatter if missing)
#   3. Places converted agents in .claude/agents/
#   4. Does NOT delete originals — Cursor agents are preserved
#
# The converted agents become project-level overrides that take priority
# over the global agents installed via install-global.sh.

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <project-path>"
  echo ""
  echo "Converts .cursor/agents/*.md to .claude/agents/ format."
  echo "Original Cursor agents are NOT modified or deleted."
  exit 1
fi

PROJECT="$1"
CURSOR_DIR="$PROJECT/.cursor/agents"
CLAUDE_DIR="$PROJECT/.claude/agents"

if [ ! -d "$CURSOR_DIR" ]; then
  echo "No Cursor agents found at: $CURSOR_DIR"
  exit 0
fi

echo "=== Cursor → Claude Code Agent Migration ==="
echo "Source: $CURSOR_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

mkdir -p "$CLAUDE_DIR"

migrated=0
skipped=0

for cursor_agent in "$CURSOR_DIR"/*.md; do
  [ -f "$cursor_agent" ] || continue
  name=$(basename "$cursor_agent")
  target="$CLAUDE_DIR/$name"

  # Skip if Claude Code version already exists (don't overwrite overrides)
  if [ -f "$target" ] && [ ! -L "$target" ]; then
    echo "  ~ SKIP $name (Claude Code version already exists)"
    skipped=$((skipped + 1))
    continue
  fi

  # Check if file already has YAML frontmatter
  first_line=$(head -1 "$cursor_agent")
  if [ "$first_line" = "---" ]; then
    # Already has frontmatter — copy as-is
    cp "$cursor_agent" "$target"
    echo "  + $name (has frontmatter, copied as-is)"
  else
    # Needs frontmatter — extract name from filename and add basic frontmatter
    agent_name=$(basename "$name" .md)

    # Extract first heading as description (if exists)
    description=$(grep -m1 '^#' "$cursor_agent" 2>/dev/null | sed 's/^#* *//')
    if [ -z "$description" ]; then
      description="Migrated from Cursor agent: $agent_name"
    fi

    cat > "$target" <<FRONTMATTER
---
name: $agent_name
description: "$description"
tools: Read, Grep, Glob, Bash, Edit, Write
model: sonnet
---

FRONTMATTER
    cat "$cursor_agent" >> "$target"
    echo "  + $name (added frontmatter)"
  fi

  migrated=$((migrated + 1))
done

echo ""
echo "=== Migration Complete ==="
echo "Migrated: $migrated"
echo "Skipped:  $skipped"
echo ""
echo "Original Cursor agents preserved at: $CURSOR_DIR"
echo "Claude Code agents created at: $CLAUDE_DIR"
echo ""
echo "Next steps:"
echo "  1. Review migrated agents in $CLAUDE_DIR"
echo "  2. Update tool lists if needed (Cursor tools ≠ Claude Code tools)"
echo "  3. Test in a Claude Code session"

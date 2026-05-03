#!/usr/bin/env bash
# Restore mtimes so drift detection sees foo.md as newer than foo.toml.
# WORKDIR is set by the test runner to the temp directory.
touch -d "2026-05-01" "$WORKDIR/.codex/agents/foo.toml"
touch -d "2026-05-03" "$WORKDIR/.claude/agents/foo.md"

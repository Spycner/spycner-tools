#!/usr/bin/env bash
# Restore mtimes so drift detection sees CLAUDE.md as newer than AGENTS.md.
# WORKDIR is set by the test runner to the temp directory.
touch -d "2026-05-01" "$WORKDIR/AGENTS.md"
touch -d "2026-05-03" "$WORKDIR/CLAUDE.md"

#!/usr/bin/env bash
# Set mtimes so drift detection sees mixed canonical sides:
# root: CLAUDE.md newer than AGENTS.md
# sub:  AGENTS.md newer than sub/CLAUDE.md
touch -d "2026-05-01" "$WORKDIR/AGENTS.md"
touch -d "2026-05-03" "$WORKDIR/CLAUDE.md"
touch -d "2026-05-01" "$WORKDIR/sub/CLAUDE.md"
touch -d "2026-05-03" "$WORKDIR/sub/AGENTS.md"

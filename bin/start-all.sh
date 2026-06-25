#!/bin/bash
# start-all.sh — start both sessions (PO + Developer) detached
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$SCRIPT_DIR")"

[ -f "$REPO/.env" ] || { echo "ERROR: $REPO/.env missing — cp .env.example .env" >&2; exit 1; }
source "$REPO/.env"

TEAM="${TEAM_NAME:?TEAM_NAME missing in .env}"

echo "Starting PO ($TEAM-po)..."
"$SCRIPT_DIR/po-ctl" -r

echo "Starting Developer ($TEAM-developer)..."
"$SCRIPT_DIR/dev-ctl" -r

echo ""
echo "✅ Both sessions running:"
echo "   tmux attach -t $TEAM-po          → Product Owner"
echo "   tmux attach -t $TEAM-developer   → Developer"
echo ""
echo "Or use the installed commands:"
echo "   $TEAM-po [-r]"
echo "   $TEAM-developer [-r]"

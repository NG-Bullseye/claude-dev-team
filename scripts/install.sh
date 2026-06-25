#!/bin/bash
# install.sh — create system command symlinks from .env config
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$SCRIPT_DIR")"

[ -f "$REPO/.env" ] || { echo "ERROR: $REPO/.env missing — cp .env.example .env" >&2; exit 1; }
source "$REPO/.env"

TEAM="${TEAM_NAME:?TEAM_NAME missing in .env}"

chmod +x "$REPO/bin/po-ctl" "$REPO/bin/dev-ctl" \
         "$REPO/bin/ensure-monitors.sh" "$REPO/bin/start-all.sh"

mkdir -p "$HOME/.local/bin"

ln -sf "$REPO/bin/po-ctl"  "$HOME/.local/bin/$TEAM-po"
echo "✅ ~/.local/bin/$TEAM-po  →  bin/po-ctl"

ln -sf "$REPO/bin/dev-ctl" "$HOME/.local/bin/$TEAM-developer"
echo "✅ ~/.local/bin/$TEAM-developer  →  bin/dev-ctl"

echo ""
echo "Commands available:"
echo "  $TEAM-po              → attach / start PO session"
echo "  $TEAM-po -r           → fresh restart PO"
echo "  $TEAM-developer       → attach / start Developer session"
echo "  $TEAM-developer -r    → fresh restart Developer"
echo "  bin/start-all.sh      → start both at once"

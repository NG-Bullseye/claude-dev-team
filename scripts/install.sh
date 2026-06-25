#!/bin/bash
# install.sh — Symlinks für System-Kommandos einrichten
# Erwartet ausgefüllte .env im Repo-Root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$REPO/.env" ]; then
  echo "FEHLER: $REPO/.env fehlt — 'cp .env.example .env' und ausfüllen." >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$REPO/.env"

PO_NAME="${PO_AGENT_NAME:?PO_AGENT_NAME fehlt in .env}"
CODING_NAME="${CODING_AGENT_NAME:-coding-agent}"

chmod +x "$REPO/bin/po-agentctl" "$REPO/bin/coding-agentctl" \
         "$REPO/bin/ensure-monitors.sh" "$REPO/bin/start-all.sh"

mkdir -p "$HOME/.local/bin"

ln -sf "$REPO/bin/po-agentctl" "$HOME/.local/bin/$PO_NAME"
echo "✅ ~/.local/bin/$PO_NAME → $REPO/bin/po-agentctl"

ln -sf "$REPO/bin/coding-agentctl" "$HOME/.local/bin/$PO_NAME-$CODING_NAME"
echo "✅ ~/.local/bin/$PO_NAME-$CODING_NAME → $REPO/bin/coding-agentctl"

echo ""
echo "Verfügbare Kommandos:"
echo "  $PO_NAME              → PO-Agent attach/start"
echo "  $PO_NAME -r           → PO-Agent frischer Neustart"
echo "  $PO_NAME-$CODING_NAME → Coding-Agent attach/start"
echo "  Beide starten: bin/start-all.sh"

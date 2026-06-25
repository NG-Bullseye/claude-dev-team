#!/bin/bash
# start-all.sh — Startet beide Sessions (PO-Agent + Coding-Agent) detached
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$REPO/.env" ]; then
  echo "FEHLER: $REPO/.env fehlt — 'cp .env.example .env' und ausfüllen." >&2
  exit 1
fi

echo "Starte PO-Agent..."
"$SCRIPT_DIR/po-agentctl" -r

echo "Starte Coding-Agent..."
"$SCRIPT_DIR/coding-agentctl" -r

source "$REPO/.env"
PO_NAME="${PO_AGENT_NAME:-po-agent}"
CODING_NAME="${CODING_AGENT_NAME:-coding-agent}"

echo ""
echo "✅ Beide Sessions laufen:"
echo "   tmux attach -t $PO_NAME          → PO-Agent"
echo "   tmux attach -t $PO_NAME-$CODING_NAME  → Coding-Agent"

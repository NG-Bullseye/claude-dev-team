#!/bin/bash
# ensure-monitors.sh — PO-Agent Monitor-Init
# Auto-gestartet via UserPromptSubmit-Hook. Idempotenz via flock.
# Lade .env aus dem Repo-Root für den Namen.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$SCRIPT_DIR")"

if [ -f "$REPO/.env" ]; then
  # shellcheck source=/dev/null
  source "$REPO/.env"
fi

NAME="${PO_AGENT_NAME:-po-agent}"
MON="$HOME/.cache/$NAME/monitors"
mkdir -p "$MON"

start_monitor() {
  nohup flock -n "$MON/$1.lock" bash -c "$2" >> "$MON/$1.log" 2>&1 &
}

# Heartbeat: Smoketest des Hook→Monitor-Mechanismus
start_monitor heartbeat "while true; do echo \"\$(date -Iseconds) $NAME alive\"; sleep 60; done"

# --- Domänen-spezifische Monitore hier einkommentieren ---
# Beispiel für coord-Integration (nur wenn COORD_ENABLED=true in .env):
# if [ "${COORD_ENABLED:-false}" = "true" ]; then
#   start_monitor agent-chat "coord monitor $NAME"
# fi
#
# Beispiel für Task-Stream-Monitor:
# start_monitor tasks "while true; do <dein-task-stream-command>; sleep 5; done"

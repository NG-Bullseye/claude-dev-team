#!/bin/bash
# ensure-monitors.sh — PO-Agent Monitor-Init
# Auto-gestartet via UserPromptSubmit-Hook. Idempotenz via flock.
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

# agent-mesh Integration (github.com/NG-Bullseye/agent-mesh)
# Wenn MESH_ENABLED=true: Singleton-Monitor-Daemon für eingehende Nachrichten.
# Schreibt DIRECT-Nachrichten nach ~/.cache/agent-mesh/notify-<name>.log
# → harness-Monitor (Monitor-Tool, in CLAUDE.md Session-Init) weckt die Session.
if [ "${MESH_ENABLED:-false}" = "true" ]; then
  if command -v agent-mesh >/dev/null 2>&1; then
    export AGENT_MESH_REDIS_URL="${MESH_REDIS_URL:-redis://localhost:6379/0}"
    export AGENT_MESH_PREFIX="${MESH_PREFIX:-mesh}"
    # Singleton via flock — kein doppelter Daemon möglich
    start_monitor mesh-monitor "agent-mesh monitor $NAME"
  else
    echo "$(date -Iseconds) WARN: MESH_ENABLED=true aber agent-mesh nicht gefunden (pip install -e ~/repos/agent-mesh)" >> "$MON/heartbeat.log"
  fi
fi

# --- Domänen-spezifische Monitore hier einkommentieren ---
# start_monitor tasks "while true; do <task-stream-command>; sleep 5; done"

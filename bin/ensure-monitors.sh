#!/bin/bash
# ensure-monitors.sh — PO monitor init, fired via UserPromptSubmit hook (idempotent via flock)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$SCRIPT_DIR")"

[ -f "$REPO/.env" ] && source "$REPO/.env"

TEAM="${TEAM_NAME:-my-team}"
SESSION="$TEAM-po"
MON="$HOME/.cache/$SESSION/monitors"
mkdir -p "$MON"

start_monitor() {
  nohup flock -n "$MON/$1.lock" bash -c "$2" >> "$MON/$1.log" 2>&1 &
}

# Heartbeat: smoke-test that the hook→monitor chain works
start_monitor heartbeat "while true; do echo \"\$(date -Iseconds) $SESSION alive\"; sleep 60; done"

# agent-mesh integration (github.com/NG-Bullseye/agent-mesh)
# DIRECT messages land in ~/.cache/agent-mesh/notify-<session>.log
# → a harness Monitor (armed in CLAUDE.md Session-Init) wakes the session
if [ "${MESH_ENABLED:-false}" = "true" ]; then
  if command -v agent-mesh >/dev/null 2>&1; then
    export AGENT_MESH_REDIS_URL="${MESH_REDIS_URL:-redis://localhost:6379/0}"
    export AGENT_MESH_PREFIX="${MESH_PREFIX:-mesh}"
    start_monitor mesh-monitor "agent-mesh monitor $SESSION"
  else
    echo "$(date -Iseconds) WARN: MESH_ENABLED=true but agent-mesh not found (pip install -e ~/repos/agent-mesh)" >> "$MON/heartbeat.log"
  fi
fi

# --- Add domain-specific monitors below ---
# start_monitor my-stream "while true; do <command>; sleep 5; done"

# claude-dev-team — Architecture Diagram

## Two-repo composability

```
┌──────────────────────────────────────────────┐   ┌─────────────────────────────────────────────────┐
│  github.com/NG-Bullseye/agent-mesh           │   │  github.com/NG-Bullseye/claude-dev-team         │
│  Transport Layer                             │   │  Runtime Structure                              │
│                                              │   │                                                 │
│  • Redis Streams                             │   │  • Product Owner session (<team>-po)            │
│    mesh:group / mesh:to_<name>               │   │  • Developer session (<team>-developer)         │
│  • CLI: agent-mesh send/listen/monitor/...   │   │  • Launchers (po-ctl / dev-ctl)                 │
│  • MCP: mesh_send / mesh_request / mesh_who  │   │  • ensure-monitors.sh + flock idempotency       │
│  • Registry (180s TTL lease)                 │   │  • CLAUDE.md templates (PO + Developer)         │
│  • Rate gate + pending ledger                │   │  • One .env — zero hardcoded slugs              │
│                                              │   │                                                 │
│  EXPOSES:                                    │   │  EXPOSES:                                       │
│  • `agent-mesh` CLI                         ◄──►│  • `<team>-po` CLI  (tmux session)              │
│  • `agent-mesh serve` MCP server             │   │  • `<team>-developer` CLI  (tmux session)       │
│  • notify log per agent                      │   │  • MESH_ENABLED hook in ensure-monitors         │
│    ~/.cache/agent-mesh/notify-<name>.log     │   │                                                 │
└──────────────────────────────────────────────┘   └─────────────────────────────────────────────────┘

         Integration interface (opt-in via .env):
         MESH_ENABLED=true  +  MESH_REDIS_URL=redis://...
         → ensure-monitors.sh starts  agent-mesh monitor <team>-po
         → Session Init registers PO + arms harness Monitor on notify log
         → Communication via  agent-mesh CLI  or  mesh_* MCP tools
```

---

## Internal structure

```
╔════════════════════════════════════════════════════════════════════╗
║                     MESH / EXTERNAL                                ║
║  other agents, watchdog, Telegram, direct callers, ...             ║
║                                                                    ║
║  [MESH_ENABLED=false]  direct tmux-send                            ║
║  [MESH_ENABLED=true ]  agent-mesh send <team>-po "task: ..."       ║
╚════════════════════════╤═══════════════════════════════════════════╝
                         │
                         ▼
╔════════════════════════════════════════════════════════════════════╗
║  PRODUCT OWNER  (<team>-po)        tmux session: <team>-po        ║
║  ~/repos/<team>/                                                   ║
║                                                                    ║
║  ┌─────────────────────────────────────────────────────────────┐   ║
║  │ CLAUDE.md       — role, domain knowledge, delegation flow   │   ║
║  │ docs/           — domain docs (templates, known pitfalls)   │   ║
║  │ ensure-monitors.sh  ← UserPromptSubmit hook                 │   ║
║  │   ├ heartbeat (always)                                      │   ║
║  │   └ agent-mesh monitor <team>-po  (MESH_ENABLED=true)       │   ║
║  │ harness Monitor on notify-<team>-po.log  (wakes session)    │   ║
║  └─────────────────────────────────────────────────────────────┘   ║
║                                                                    ║
║  receive task → read docs → plan → cut spec                        ║
║                         │                                          ║
║                         │  tmux send-keys → Developer              ║
║                         ▼                                          ║
║  ┌─────────────────────────────────────────────────────────────┐   ║
║  │  DEVELOPER  (<team>-developer)  tmux: <team>-developer      │   ║
║  │  ~/repos/<team>/developer/                                  │   ║
║  │                                                             │   ║
║  │  implement → deploy → verify → report done to PO           │   ║
║  └─────────────────────────────────────────────────────────────┘   ║
╚════════════════════════════════════════════════════════════════════╝
                         │
                         │  done: live + merged + verified
                         ▼
╔════════════════════════════════════════════════════════════════════╗
║  CALLER / MESH                                                     ║
║  [MESH_ENABLED=true]   via  agent-mesh send/reply                  ║
║  [MESH_ENABLED=false]  via  tmux / direct session                  ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## Filesystem layout

```
~/repos/<team>/                       ← Product Owner repo  (tmux: <team>-po)
├── .env                              ← all config  (gitignored)
├── .env.example                      ← template   (committed)
├── CLAUDE.md                         ← PO identity + session init
├── bin/
│   ├── po-ctl                        → ~/.local/bin/<team>-po
│   ├── dev-ctl                       → ~/.local/bin/<team>-developer
│   ├── ensure-monitors.sh            ← heartbeat + optional agent-mesh monitor
│   └── start-all.sh
├── docs/
│   └── [domain docs]                 ← drop domain knowledge here
└── developer/                        ← Developer repo  (tmux: <team>-developer)
    ├── CLAUDE.md
    └── .claude/settings.json

~/.cache/agent-mesh/
└── notify-<team>-po.log              ← harness Monitor waker  (MESH_ENABLED=true)

~/.cache/<team>-po/monitors/
├── heartbeat.{lock,log}
└── mesh-monitor.{lock,log}           ← agent-mesh monitor daemon  (MESH_ENABLED=true)
```

---

## Reference instance: microcontroller-agent

```
TEAM_NAME=microcontroller-agent
PO_MODEL=sonnet
DEVELOPER_MODEL=sonnet
MESH_ENABLED=true

tmux sessions:
  microcontroller-agent-po          ← Mesh entry point for embedded/display tasks
  microcontroller-agent-developer   ← ESPHome / LVGL implementer

Domain docs to place in docs/:
  • ESPHome documentation
  • CYD display guide  (rotation, color profiles, mirror — this is the known pitfall!)
  • LVGL coordinate system  (orientation is non-obvious — read before building!)
  • Cortex Terminal templates + Makefile targets
  • Reference builds: ~/esp_repos/cortex-terminal/  (CortexTerminal 1 + 2)
```

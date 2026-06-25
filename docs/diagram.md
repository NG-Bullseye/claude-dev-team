# Agent-Pair-Template — Architektur-Diagramm

## Zwei-Repo-Composability

```
┌─────────────────────────────────────────────┐   ┌──────────────────────────────────────────────┐
│  github.com/NG-Bullseye/agent-mesh          │   │  github.com/NG-Bullseye/agent-pair-template  │
│  Transport Layer                            │   │  Runtime Structure                           │
│                                             │   │                                              │
│  • Redis Streams (mesh:group / mesh:to_X)  │   │  • PO-Agent (Domain Specialist)              │
│  • CLI: agent-mesh send/listen/monitor/...  │   │  • Coding-Agent (Nested Implementer)         │
│  • MCP: mesh_send / mesh_request / mesh_who │   │  • Launchers + ensure-monitors + hooks       │
│  • Registry (180s TTL-Lease)                │   │  • CLAUDE.md templates                       │
│  • Rate Gate + Pending Ledger               │   │  • .env-driven, zero hardcoded slugs         │
│                                             │   │                                              │
│  EXPOSES:                                   │   │  EXPOSES:                                    │
│  • `agent-mesh` CLI                        ◄──►│  • `<po-name>` CLI (tmux session)            │
│  • `agent-mesh serve` MCP server            │   │  • `<po-name>-coding-agent` CLI              │
│  • notify log: ~/.cache/agent-mesh/         │   │  • MESH_ENABLED hook in ensure-monitors      │
│    notify-<name>.log (harness waker)        │   │                                              │
└─────────────────────────────────────────────┘   └──────────────────────────────────────────────┘

          Integration Interface (opt-in via .env):
          MESH_ENABLED=true + MESH_REDIS_URL=redis://...
          → ensure-monitors.sh startet agent-mesh monitor <name>
          → Session-Init registriert + armt harness-Monitor auf notify log
          → Kommunikation via agent-mesh CLI oder mesh_* MCP-Tools
```

---

## Interner Aufbau: agent-pair-template

```
╔═══════════════════════════════════════════════════════════════════╗
║                        MESH / SYSTEM                              ║
║   (andere Agents, coding-agent, watchdog, Telegram, ...)          ║
║                                                                   ║
║   [MESH_ENABLED=false]  direkt via tmux-send                      ║
║   [MESH_ENABLED=true ]  agent-mesh send <po-name> "..."           ║
╚═══════════════════════════╤═══════════════════════════════════════╝
                            │
                            ▼
╔═══════════════════════════════════════════════════════════════════╗
║  PO-AGENT  (<po-name>)             tmux-Session: <po-name>        ║
║  ~/repos/<po-name>/                                               ║
║                                                                   ║
║  ┌──────────────────────────────────────────────────────────┐     ║
║  │ CLAUDE.md     — Selbstbild, Domänenwissen, Delegation    │     ║
║  │ docs/         — Domänen-Docs (Templates, Known-Pitfalls) │     ║
║  │ ensure-monitors.sh  ← UserPromptSubmit-Hook              │     ║
║  │   ├ heartbeat (immer)                                    │     ║
║  │   └ agent-mesh monitor <name> (wenn MESH_ENABLED=true)   │     ║
║  │ harness-Monitor on notify-<name>.log (weckt Session)     │     ║
║  └──────────────────────────────────────────────────────────┘     ║
║                                                                   ║
║  Aufgabe empfangen → planen (Docs lesen) → Scope schneiden        ║
║                            │                                      ║
║                            │ tmux send-keys → Coding-Agent        ║
║                            ▼                                      ║
║  ┌──────────────────────────────────────────────────────────┐     ║
║  │  CODING-AGENT  (<po-name>-coding-agent)                  │     ║
║  │  ~/repos/<po-name>/coding-agent/                         │     ║
║  │  tmux-Session: <po-name>-coding-agent                    │     ║
║  │                                                          │     ║
║  │  Code + Deploy + Verify → fertig melden an PO            │     ║
║  └──────────────────────────────────────────────────────────┘     ║
╚═══════════════════════════════════════════════════════════════════╝
                            │
                            │ fertig: live + gemerged + verifiziert
                            ▼
╔═══════════════════════════════════════════════════════════════════╗
║                    AUFTRAGGEBER / MESH                            ║
║  [MESH_ENABLED=true] via agent-mesh send/reply                    ║
║  [MESH_ENABLED=false] via tmux / direkte Session                  ║
╚═══════════════════════════════════════════════════════════════════╝
```

---

## Dateisystem-Layout

```
~/repos/<po-name>/                  ← PO-Agent-Repo (tmux: <po-name>)
├── .env                            ← alle Konfigurationen (gitignored)
├── .env.example                    ← Template (eingecheckt)
├── CLAUDE.md                       ← PO-Agent-Selbstbild
├── bin/
│   ├── po-agentctl                 ← Launcher PO  → ~/.local/bin/<po-name>
│   ├── coding-agentctl             ← Launcher CA  → ~/.local/bin/<po-name>-coding-agent
│   ├── ensure-monitors.sh          ← Heartbeat + optionaler agent-mesh Monitor
│   └── start-all.sh
├── docs/
│   └── [domain-docs/]              ← Domänen-Dokumentation
└── coding-agent/                   ← nested Coding-Agent (tmux: <po-name>-coding-agent)
    ├── CLAUDE.md
    └── .claude/settings.json

~/.cache/agent-mesh/
└── notify-<po-name>.log            ← harness-Monitor Waker (MESH_ENABLED=true)

~/.cache/<po-name>/monitors/
├── heartbeat.{lock,log}
└── mesh-monitor.{lock,log}         ← agent-mesh monitor daemon (MESH_ENABLED=true)
```

---

## Konkrete Instanz: microcontroller-agent

```
PO_AGENT_NAME=microcontroller-agent
CODING_AGENT_NAME=coding-agent
MESH_ENABLED=true
MESH_REDIS_URL=redis://localhost:6379/0

tmux: microcontroller-agent           ← Mesh-Entry-Point für Mikrocontroller-Aufgaben
tmux: microcontroller-agent-coding-agent ← ESPHome/LVGL Implementierer

Domänen-Docs (in docs/ einpflegen):
  • ESPHome-Dokumentation
  • CYD-Display-Guide (Rotation, Farb-Profile, Spiegel — Known-Pitfall!)
  • LVGL-Koordinatensystem (Orientierung nicht intuitiv — lesen bevor bauen!)
  • Cortex-Terminal-Templates + Makefile-Targets
  • Vorbilder: ~/esp_repos/cortex-terminal/ (CortexTerminal 1 + 2)
```

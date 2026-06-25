# Agent-Pair-Template — Architektur-Diagramm

## Überblick: Zweiköpfige Agent-Struktur

```
╔══════════════════════════════════════════════════════════════════╗
║                        MESH / SYSTEM                             ║
║   (coding-agent, watchdog, Telegram, direkte Aufrufe, ...)       ║
╚═══════════════════════════╤══════════════════════════════════════╝
                            │  coord send <po-name> "..."
                            │  (oder tmux send-keys direkt)
                            ▼
╔═══════════════════════════════════════════════════════════════════╗
║  PO-AGENT  (<po-name>)             tmux-Session: <po-name>       ║
║  ~/repos/<po-name>/                                              ║
║                                                                  ║
║  Rolle: Domain-Spezialist + Mesh-Entry-Point                     ║
║  ┌─────────────────────────────────────────────────────────┐     ║
║  │  CLAUDE.md      — Selbstbild, Domänenwissen, Delegation │     ║
║  │  docs/          — Domänen-Dokumentation (Templates, ...) │     ║
║  │  bin/ensure-monitors.sh   ← UserPromptSubmit-Hook       │     ║
║  │  .claude/settings.json    — Hooks + Permissions         │     ║
║  └─────────────────────────────────────────────────────────┘     ║
║                                                                  ║
║  Aufgabe empfangen → planen (Docs lesen) → Scope schneiden       ║
║                            │                                     ║
║                            │ delegiert klar abgegrenzten Scope   ║
║                            ▼                                     ║
║  ┌──────────────────────────────────────────────────────────┐    ║
║  │  CODING-AGENT  (<po-name>-coding-agent)                  │    ║
║  │  ~/repos/<po-name>/coding-agent/                         │    ║
║  │  tmux-Session: <po-name>-coding-agent                    │    ║
║  │                                                          │    ║
║  │  Rolle: Implementierer (subordiniert, intern)            │    ║
║  │  ┌────────────────────────────────────────────────┐      │    ║
║  │  │ CLAUDE.md    — Selbstbild, Scope, Lifecycle    │      │    ║
║  │  │ .claude/settings.json — bypassPermissions      │      │    ║
║  │  └────────────────────────────────────────────────┘      │    ║
║  │                                                          │    ║
║  │  Code + Deploy + Verify → fertig melden an PO           │    ║
║  └──────────────────────────────────────────────────────────┘    ║
╚═══════════════════════════════════════════════════════════════════╝
                            │
                            │  fertig: live + gemerged + verifiziert
                            ▼
╔══════════════════════════════════════════════════════════════════╗
║                    MESH / AUFTRAGGEBER                           ║
║  (PO meldet Ergebnis zurück via coord / tmux / result-file)      ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## Dateisystem-Layout

```
~/repos/<po-name>/                  ← PO-Agent-Repo (tmux: <po-name>)
├── .env                            ← alle Konfigurationen (gitignored)
├── .env.example                    ← Template (eingecheckt)
├── .gitignore
├── CLAUDE.md                       ← PO-Agent-Selbstbild
├── README.md
├── bin/
│   ├── po-agentctl                 ← Launcher PO (Symlink: ~/.local/bin/<po-name>)
│   ├── coding-agentctl             ← Launcher Coding (Symlink: ~/.local/bin/<po-name>-coding-agent)
│   ├── ensure-monitors.sh          ← PO Monitor-Init (via UserPromptSubmit-Hook)
│   └── start-all.sh                ← Beide Sessions starten
├── .claude/
│   ├── settings.json               ← Hooks: UserPromptSubmit → ensure-monitors
│   └── hooks/
│       └── clear_self.sh           ← (optional) Self-Restart bei CLEAR-READY
├── docs/
│   ├── implementation-plan.md      ← dieser Plan
│   ├── diagram.md                  ← dieses Diagramm
│   └── [domain-docs]/             ← Domänen-Dokumentation (einpflegen beim Instanziieren)
└── coding-agent/                   ← nested Coding-Agent-Repo (tmux: <po-name>-coding-agent)
    ├── CLAUDE.md                   ← Coding-Agent-Selbstbild
    └── .claude/
        └── settings.json           ← bypassPermissions
```

---

## tmux-Sessions

```
tmux ls:
  <po-name>                ← PO-Agent    (attach: po-agentctl oder <po-name>)
  <po-name>-coding-agent   ← Coding-Agent (attach: coding-agentctl)
```

---

## Cache-Verzeichnisse

```
~/.cache/<po-name>/
├── launcher/<po-name>.sid            ← Session-ID für --resume
└── monitors/
    ├── heartbeat.lock                ← flock-Mutex (gehalten = läuft)
    ├── heartbeat.log                 ← "alive"-Zeilen
    └── [weitere-monitore]/

~/.cache/<po-name>-coding-agent/
└── launcher/coding-agent.sid         ← Session-ID Coding-Agent
```

---

## Konkrete Instanz: microcontroller-agent

```
~/repos/microcontroller-agent/
  PO:     tmux-Session "microcontroller-agent"
  Coding: tmux-Session "microcontroller-agent-coding-agent"
  Docs:   ESPHome-Docs, Cortex-Terminal-Templates, CYD-Display-Guide,
          Vorbilder cortex-terminal 1+2 (LESEN bevor irgendwas gebaut wird)
  Mesh:   coord-Integration (COORD_ENABLED=true, nach coord-Eintrag)
```

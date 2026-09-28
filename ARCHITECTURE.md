# ARCHITECTURE — agent-pair-template

## Deep Modules — PO + Developer als zwei tmux-Sessions

Flow: `.env` → `scripts/install.sh` legt Launcher-Symlinks → `bin/start-all.sh` startet PO und Developer → UserPromptSubmit-hook ruft `bin/ensure-monitors.sh`. Es gibt keine eigene Flow-Datei; die Sequenz lebt in `bin/start-all.sh`. Jede Innenleben-Zelle ist datei:zeile und muss per grep -n treffen.

## Flow

**Sequenz**

| # | Modul | Eingang | Ausgang | Bedingung | Stellschraube | Innenleben |
|---|---|---|---|---|---|---|
| 1 | install | `.env` | `~/.local/bin/<team>-po`, `<team>-developer` | `.env` existiert | `TEAM_NAME` | scripts/install.sh:18 `ln -sf` |
| 2 | po-ctl | Aufruf, `-r` | tmux-Session `<team>-po` mit `claude --session-id` | Session fehlt oder `-r` | `.env` Modelle | bin/po-ctl:25 `start_fresh` |
| 3 | dev-ctl | Aufruf, `-r` | tmux-Session `<team>-developer` | Session fehlt oder `-r` | `.env` Modelle | bin/dev-ctl:26 `start_fresh` |

**Parallel**

| Modul | Eingang | Ausgang | Bedingung | Stellschraube | Innenleben |
|---|---|---|---|---|---|
| ensure-monitors | UserPromptSubmit-hook | background jobs mit `flock`, Logs unter `~/.cache` | idempotent per lock | `MESH_ENABLED` | bin/ensure-monitors.sh:13 `start_monitor` |
| mesh-monitor | agent-mesh (Redis Streams) | notify-Log der Session | `MESH_ENABLED=true` | `MESH_REDIS_URL` | bin/ensure-monitors.sh:23 `MESH_ENABLED` |

## Schnittstellen

- SID-Datei `~/.cache/<session>/launcher/<session>.sid` (bin/po-ctl:18 `SID_FILE`) trägt die Session-ID für Resume.
- Mesh optional über `agent-mesh`; ohne Mesh keine Schnittstelle nach außen.

## Standard: Deep Modules + Flow

Standard R1–R5 steht in `~/repos/speech-engine/ARCHITECTURE.md`.

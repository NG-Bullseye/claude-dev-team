# Agent-Pair-Template — Implementierungsplan

> Dieser Plan beschreibt wie ein konkretes Agent-Paar aus diesem Template instanziiert wird.
> Referenz-Implementierung: `microcontroller-agent` (PO) + nested `coding-agent`.
> Diagram: siehe `diagram.md`.

---

## Architektur-Überblick

Das Template implementiert ein **zweiköpfiges Agent-Paar**:

| Rolle | Session | Repo-Pfad | Mesh-Sichtbar |
|---|---|---|---|
| **PO-Agent** | `<po-name>` | `~/repos/<po-name>/` | Ja — einziger Ansprechpartner |
| **Coding-Agent** | `<po-name>-coding-agent` | `~/repos/<po-name>/coding-agent/` | Nein — intern |

Der PO ist der **einzige Mesh-Entry-Point**. Extern spricht niemand den coding-agent direkt an.
Der coding-agent ist ein *Werkzeug* des PO, nicht ein eigenständiger Mesh-Teilnehmer.

---

## Instanziierungs-Schritte (für den ausführenden Agent)

### Phase 1 — Repo anlegen

```bash
# 1. .env befüllen (alle Slugs + Modelle + Pfade)
cp .env.example .env
$EDITOR .env

# 2. Repo mit richtigem Namen klonen/kopieren
source .env
TARGET="$HOME/repos/$PO_AGENT_NAME"
cp -r ~/repos/agent-pair-template "$TARGET"
cd "$TARGET" && git init -q

# 3. coding-agent Subdir initialisieren
mkdir -p coding-agent/.claude
```

### Phase 2 — CLAUDE.md-Dateien befüllen

**PO-Agent `CLAUDE.md`** (`~/repos/<po-name>/CLAUDE.md`):
- `[PO_AGENT_NAME]` → echter Slug
- `[DOMAIN]` → Domäne (z.B. „Mikrocontroller/ESPHome-Displays")
- Session-Init-Monitore korrekt eintragen

**Coding-Agent `CLAUDE.md`** (`~/repos/<po-name>/coding-agent/CLAUDE.md`):
- `[CODING_AGENT_NAME]` → `coding-agent`
- `[PO_AGENT_NAME]` → PO-Slug eintragen

### Phase 3 — settings.json korrekt setzen

Für PO-Agent (`.claude/settings.json`):
```json
{
  "permissions": { "defaultMode": "bypassPermissions" },
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [ { "type": "command", "command": "bash ~/repos/<po-name>/bin/ensure-monitors.sh" } ] }
    ]
  }
}
```

Für Coding-Agent (`coding-agent/.claude/settings.json`):
```json
{
  "permissions": { "defaultMode": "bypassPermissions" }
}
```

### Phase 4 — Launcher + Symlinks

```bash
source .env
chmod +x bin/po-agentctl bin/coding-agentctl bin/start-all.sh bin/ensure-monitors.sh

# Symlinks — Namen aus .env
ln -sf "$HOME/repos/$PO_AGENT_NAME/bin/po-agentctl" "$HOME/.local/bin/$PO_AGENT_NAME"
ln -sf "$HOME/repos/$PO_AGENT_NAME/bin/coding-agentctl" "$HOME/.local/bin/$PO_AGENT_NAME-coding-agent"
```

### Phase 5 — Domänen-Docs einpflegen

Alle domänenspezifischen Dokumentationen in `docs/` ablegen:
- Templates, Design-Guides, Beispiele
- Links zu Vorbilder-Repos
- Known-Pitfalls (besonders wichtig: was beim letzten Versuch falsch war)

### Phase 6 — coord-Integration (optional, nur wenn Mesh-Routing nötig)

1. `~/.local/bin/coord` editieren: `VALID_AGENTS` um `<po-name>` erweitern (Zeile ~65)
2. `self_alias`-Mapping ergänzen (~Zeile 432)
3. `coord monitor` daemon respawnen
4. `COORD_ENABLED=true` in `.env` setzen
5. `ensure-monitors.sh` aktiviert dann automatisch den coord-Monitor

### Phase 7 — Verify

```bash
source .env
bin/start-all.sh   # startet beide Sessions detached

# PO-Session verifizieren
tmux has-session -t "$PO_AGENT_NAME" && echo "PO läuft"
sleep 3 && ls ~/.cache/$PO_AGENT_NAME/monitors/  # heartbeat.lock + heartbeat.log

# Coding-Agent-Session verifizieren
tmux has-session -t "$PO_AGENT_NAME-coding-agent" && echo "Coding läuft"
```

---

## Kommunikations-Muster

### PO → Coding-Agent (Aufgaben-Delegation)

```bash
# Option A: tmux send-keys (einfachste Form, kein coord nötig)
tmux send-keys -t "${PO_AGENT_NAME}-coding-agent" "Implementiere X: [klare Beschreibung]" Enter

# Option B: Shared file / queue (für komplexere Specs)
echo "TASK: ..." > ~/repos/$PO_AGENT_NAME/.task-queue
```

### Coding-Agent → PO (Fertig-Meldung)

```bash
# Coding-Agent schreibt in ein shared result file
echo "DONE: X implementiert, verifiziert via Y" > ~/repos/$PO_AGENT_NAME/.task-result
# PO-Agent hat einen Monitor auf dieses File (oder polling via harness-Monitor)
```

### Mesh → PO (extern)

Über coord (`coord send <po-name> "Aufgabe: ..."`) oder direkt via tmux-send.
Der PO ist der einzige externe Ansprechpartner.

---

## Konkrete Instanziierung: microcontroller-agent

Für den `microcontroller-agent` (Krisen-Radar + zukünftige Cortex-Terminals):

| Parameter | Wert |
|---|---|
| `PO_AGENT_NAME` | `microcontroller-agent` |
| `CODING_AGENT_NAME` | `coding-agent` |
| `PO_AGENT_MODEL` | `sonnet` |
| `COORD_ENABLED` | `true` (nach coord-Eintrag) |
| Domänen-Docs | ESPHome-Docs, Cortex-Terminal-Templates, CYD-Display-Guide, Vorbilder Terminal 1+2 |

**Known-Pitfalls (aus dem gescheiterten Krisen-Radar-Versuch):**
- Der Agent muss die CYD-Display-Rotation, Farb-Profile und Spiegel-Einstellungen kennen
- Vorbilder (`cortex-terminal` Repo) LESEN bevor irgendwas gebaut wird
- Das Template-Script zum Flashen und die Makefile-Targets existieren bereits — nicht neu erfinden
- LVGL-Koordinatensystem-Orientierung ist nicht intuitiv: Docs zuerst

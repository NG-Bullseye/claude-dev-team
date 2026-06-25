# agent-pair-template

Agnostisches Template für ein **zweiköpfiges Agent-Paar**: Domain-Spezialist PO-Agent (Mesh-Entry-Point) + nested Coding-Agent (Implementierer). Alle Konfigurationen in `.env`.

Composable mit **[agent-mesh](https://github.com/NG-Bullseye/agent-mesh)** (Transport-Layer) — `MESH_ENABLED=true` verbindet beide ohne Code-Änderung.

## Schnellstart (standalone)

```bash
cp .env.example .env
$EDITOR .env                    # PO_AGENT_NAME, DOMAIN_DOCS_PATH etc. setzen
bash scripts/install.sh         # Symlinks einrichten
bash bin/start-all.sh           # beide Sessions starten
```

## Mit agent-mesh (empfohlen)

```bash
# 1. agent-mesh installieren + Redis starten
git clone https://github.com/NG-Bullseye/agent-mesh ~/repos/agent-mesh
cd ~/repos/agent-mesh && pip install -e . && docker-compose up -d

# 2. agent-pair-template konfigurieren
cp .env.example .env
# In .env setzen:
#   MESH_ENABLED=true
#   MESH_REDIS_URL=redis://localhost:6379/0
bash scripts/install.sh && bash bin/start-all.sh

# Andere Agents können jetzt kommunizieren:
agent-mesh send <po-name> "Aufgabe: ..."
agent-mesh who
```

## Architektur

```
[agent-mesh Transport]          [agent-pair-template Runtime]
 Redis Streams + MCP    ──────►  PO-Agent (<po-name>)
 agent-mesh send/listen          └─ Coding-Agent (<po-name>-coding-agent)
```

Details + vollständiges Diagramm: `docs/diagram.md` und `docs/implementation-plan.md`.

## Instanziieren für eine konkrete Domäne

1. `.env` befüllen (alle Slugs + `MESH_ENABLED`)
2. `CLAUDE.md` + `coding-agent/CLAUDE.md` Platzhalter ersetzen
3. Domänen-Docs in `docs/` einpflegen
4. `bash scripts/install.sh && bash bin/start-all.sh`

Referenz-Instanz: `microcontroller-agent` (ESPHome, Cortex-Terminals).

# agent-pair-template

Agnostisches Template für ein **zweiköpfiges Agent-Paar**: Domain-Spezialist PO-Agent (Mesh-Entry-Point) + nested Coding-Agent (Implementierer). Alle Konfigurationen in `.env`.

## Schnellstart

```bash
cp .env.example .env
$EDITOR .env                    # PO_AGENT_NAME, DOMAIN_DOCS_PATH etc. setzen
bash scripts/install.sh         # Symlinks einrichten
bash bin/start-all.sh           # beide Sessions starten
```

## Architektur

```
Mesh → PO-Agent (<po-name>) → Coding-Agent (<po-name>-coding-agent)
```

- **PO-Agent**: Domain-Spezialist, Mesh-Entry-Point, plant + delegiert
- **Coding-Agent**: Implementierer, subordiniert, code + deploy + verify

Details: `docs/diagram.md` und `docs/implementation-plan.md`.

## Instanziieren für eine konkrete Domäne

1. `.env` befüllen (alle Slugs)
2. `CLAUDE.md` + `coding-agent/CLAUDE.md` mit echten Namen + Domänenbeschreibung befüllen
3. Domänen-Docs in `docs/` einpflegen
4. Bei coord-Mesh-Integration: `~/.local/bin/coord` editieren + `COORD_ENABLED=true`

Referenz-Instanz: `microcontroller-agent` (ESPHome, Cortex-Terminals).

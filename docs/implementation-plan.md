# claude-dev-team — Instantiation Plan

> How to create a concrete team from this template.
> Reference: `microcontroller-agent` (PO) + `developer`.
> See `diagram.md` for the architecture picture.

---

## Overview

| Role | tmux session | Repo path | Mesh-visible |
|---|---|---|---|
| **Product Owner** | `<team>-po` | `~/repos/<team>/` | Yes — sole entry point |
| **Developer** | `<team>-developer` | `~/repos/<team>/developer/` | No — internal |

The PO is the **only external contact**. Nobody talks to the Developer directly.

---

## Instantiation steps

### Phase 1 — Repo setup

```bash
# Clone or copy the template
git clone https://github.com/NG-Bullseye/claude-dev-team ~/repos/<team>
cd ~/repos/<team>
cp .env.example .env
```

Set in `.env`:
- `TEAM_NAME=<team>`  — the slug used for sessions, cache paths, and symlinks
- `PO_MODEL` / `DEVELOPER_MODEL` — sonnet for most tasks
- `MESH_ENABLED=true` if connecting to an agent-mesh network

### Phase 2 — CLAUDE.md placeholders

**`CLAUDE.md`** (Product Owner):
- Replace `[TEAM_NAME]` with your slug
- Replace `[DOMAIN]` with the domain description

**`developer/CLAUDE.md`** (Developer):
- Replace `[TEAM_NAME]` with your slug

### Phase 3 — Domain docs

Drop all domain-relevant documentation into `docs/`:
- Templates, design guides, style guides
- Known pitfalls from previous attempts
- Reference repos / example builds

The PO reads these before every task. The quality of the PO's planning
is directly proportional to what lives in `docs/`.

### Phase 4 — Install

```bash
bash scripts/install.sh      # creates ~/.local/bin/<team>-po and <team>-developer
bash bin/start-all.sh        # starts both sessions detached
```

### Phase 5 — agent-mesh (optional)

```bash
# Install transport layer
git clone https://github.com/NG-Bullseye/agent-mesh ~/repos/agent-mesh
cd ~/repos/agent-mesh && pip install -e . && docker-compose up -d

# In .env: MESH_ENABLED=true
# Restart: bash bin/start-all.sh

# Verify
agent-mesh who               # should list <team>-po
agent-mesh ping <team>-po    # should pong
```

### Phase 6 — Verify

```bash
source .env
tmux has-session -t "$TEAM_NAME-po" && echo "PO running"
tmux has-session -t "$TEAM_NAME-developer" && echo "Developer running"
sleep 3
ls ~/.cache/$TEAM_NAME-po/monitors/   # heartbeat.lock + heartbeat.log present?
flock -n ~/.cache/$TEAM_NAME-po/monitors/heartbeat.lock true \
  && echo "WARN: monitor not running" || echo "OK: heartbeat monitor running"
```

---

## Communication patterns

### External → PO

```bash
# Via mesh (MESH_ENABLED=true)
agent-mesh send <team>-po "Task: build feature X"
agent-mesh request <team>-po "what is the status?" --from my-agent

# Via tmux (always works)
tmux send-keys -t <team>-po "Task: build feature X" Enter
```

### PO → Developer

```bash
# PO delegates via tmux (Developer session is always local)
tmux send-keys -t <team>-developer "Implement X: <clear spec>" Enter
```

### Developer → PO (done signal)

```bash
# Write to a shared result file the PO monitors
echo "DONE: X implemented, verified via Y" > ~/repos/<team>/.task-result
# Or: PO polls / the Developer messages back via tmux
tmux send-keys -t <team>-po "Done: X live and verified" Enter
```

---

## Reference: microcontroller-agent

```
TEAM_NAME=microcontroller-agent
MESH_ENABLED=true

Sessions:
  microcontroller-agent-po          ← entry point for embedded/display requests
  microcontroller-agent-developer   ← ESPHome / LVGL implementer

Critical domain docs (docs/ must contain):
  • ESPHome docs
  • CYD display guide (rotation, mirror, color — READ THIS, it was the last failure point)
  • LVGL coordinate system (non-intuitive orientation — always read before building)
  • Cortex Terminal build scripts + Makefile targets
  • Reference: ~/esp_repos/cortex-terminal/ (CortexTerminal 1 + 2 — working builds)
```

# claude-dev-team

A **Claude Code mini developer team** template: Product Owner + Developer, two persistent tmux sessions, zero API keys. Runs entirely on a Claude Code subscription.

Composable with **[agent-mesh](https://github.com/NG-Bullseye/agent-mesh)** — set `MESH_ENABLED=true` to connect the team to a Redis-backed inter-agent network. Works standalone without it.

```
[agent-mesh network]           [claude-dev-team]
  other agents      ─────────►  <team>-po         (Product Owner)
  agent-mesh CLI                └─ <team>-developer  (Developer)
```

## Quick start

```bash
cp .env.example .env
# Set TEAM_NAME (and optionally MESH_ENABLED) in .env
bash scripts/install.sh         # creates ~/.local/bin/<team>-po and <team>-developer
bash bin/start-all.sh           # starts both tmux sessions
```

Sessions:
```
<team>-po          → Product Owner  (domain specialist, mesh entry point)
<team>-developer   → Developer      (implementer, subordinate to PO)
```

## With agent-mesh

```bash
# Install agent-mesh transport layer
git clone https://github.com/NG-Bullseye/agent-mesh ~/repos/agent-mesh
cd ~/repos/agent-mesh && pip install -e . && docker-compose up -d

# Enable in .env
MESH_ENABLED=true
MESH_REDIS_URL=redis://localhost:6379/0

# Restart sessions
bash bin/start-all.sh

# Other agents can now reach your team
agent-mesh send <team>-po "Build feature X"
agent-mesh who
```

## Instantiate for a domain

1. Fill in `.env` — set `TEAM_NAME`, models, `MESH_ENABLED`
2. Replace `[TEAM_NAME]` / `[DOMAIN]` placeholders in `CLAUDE.md` and `developer/CLAUDE.md`
3. Drop domain docs into `docs/` (templates, known pitfalls, examples)
4. `bash scripts/install.sh && bash bin/start-all.sh`

Reference instance: `microcontroller-agent` (ESPHome / Cortex Terminals).

## Architecture

See `docs/diagram.md` for the full picture and `docs/implementation-plan.md` for step-by-step instantiation.

## How it works

- **No API key** — both agents run as `claude` CLI processes under a Claude Code subscription
- **Persistent sessions** — SID-based resume survives restarts without losing context
- **Idempotent monitors** — `flock`-based, safe to fire multiple times (UserPromptSubmit hook)
- **Mesh-optional** — `MESH_ENABLED=false` runs fully offline; flip to `true` to join a network
- **One .env** — all slugs, models, and URLs in one place; nothing hardcoded in scripts

## License

MIT

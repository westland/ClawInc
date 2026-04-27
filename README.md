# ClawInc — OpenClaw Multi-Agent AI Company

**A deployable five-agent autonomous AI company for marketing analytics, research, and automation.**  
*MKT/IDS 518 · J. Christopher Westland · University of Illinois at Chicago*

[![Release](https://img.shields.io/badge/release-v3.50-brightgreen)](https://github.com/westland/ClawInc/releases/tag/v3.50)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-2026.4.24-blue)](https://openclaw.dev)
[![Platform](https://img.shields.io/badge/platform-Ubuntu%2024.04-orange)](https://ubuntu.com)
[![Telegram](https://img.shields.io/badge/interface-Telegram-2CA5E0)](https://telegram.org)
[![Discord](https://img.shields.io/badge/reports-Discord-5865F2)](https://discord.com)

> **[The ClawInc Educational Manifesto](MANIFESTO.md)** — The course philosophy: Personality, Action Scripts, and Taboos; Druckerian Strategic Realism; and the Zero-Marginal-Cost Agency.

---

## What Is ClawInc?

ClawInc is a multi-agent AI company that runs 24/7 on a $6/month cloud server. You control five specialized AI agents through Telegram — from any phone or computer, by voice or text — and every agent response is automatically posted to a Discord `#reports` channel for team visibility.

The five agents are:

| Agent | Model | Role | Discord Color |
|-------|-------|------|---------------|
| **Henry** | Claude Sonnet 4.6 | Chief of Staff — orchestrates the team, delegates tasks | Gold |
| **Coder** | Claude Sonnet 4.6 | Software Engineer — writes code, runs data analysis | Blue |
| **Scout** | Claude Haiku 4.5 | Research Analyst — web research, trend monitoring | Green |
| **Writer** | Claude Sonnet 4.6 | Content Creator — memos, reports, executive summaries | Purple |
| **Watcher** | Claude Haiku 4.5 | System Monitor — health checks, alerts, maintenance | Orange |

---

## What's New in v3.00

| Area | Change |
|------|--------|
| **Models** | Henry downgraded Opus 4.7 → Sonnet 4.6 (prevents OOM on 1 GB droplets) |
| **ACP delegation** | `acp.enabled: true` + `allowedAgents` — Henry can now spawn Coder/Scout/Writer/Watcher via `sessions_spawn` tool |
| **Service hardening removed** | Removed `NoNewPrivileges`, `ProtectKernelTunables`, `ProtectKernelModules`, `ProtectControlGroups`, `RestrictNamespaces`, `RestrictSUIDSGID`, `MemoryDenyWriteExecute` — these conflicted with gateway temp-file paths and caused OOM crashes |
| **IPv6 fix** | `--dns-result-order=ipv4first` in `NODE_OPTIONS` + new `deploy/fix-ipv6-hosts.sh` script for DO droplets with broken IPv6 routes to Cloudflare/GitHub |
| **DNS cache flush** | `ExecStartPre=/usr/bin/resolvectl flush-caches` — clears stale IPv6 records before gateway starts |
| **Node.js compile cache** | `NODE_COMPILE_CACHE` env var — speeds up CLI cold start after first run |
| **Memory limits** | Tuned down to `MemoryMax=800M` / `MemoryHigh=640M` (was 1200M/1024M) — realistic for Sonnet load |
| **Memory backend** | `memory.backend: builtin` (was `qmd`) — removes external memory dependency |
| **Plugin cleanup** | `OPENAI_API_KEY` removed from template; per-account `plugins.entries` blocks removed (consolidated to top-level) |


## What's New in v3.10

| Area | Change |
|------|--------|
| **Agent delegation** | Fixed native subagent spawning — `agents.defaults.subagents.allowAgents` is the correct config key (not `acp.allowedAgents`, which only controls external ACP runtimes like Claude Code CLI) |
| **Root cause** | OpenClaw source `acp-spawn-DlpFNlw8.js` reads `agents.defaults.subagents.allowAgents`; default is `[]` so all `sessions_spawn` calls were blocked with "agentId not allowed (allowed: none)" |
| **Config fix** | Added `"allowAgents": ["coder","scout","writer","watcher"]` and `"maxSpawnDepth": 2` under `agents.defaults.subagents` |
| **Delegation skill** | Added `delegate-task.md` to Henry's workspace — teaches him to use `sessions_spawn` instead of attempting Telegram bot-to-bot messaging (impossible: bots can't initiate chats with other bots) |
| **Scope upgrade fix** | Granted the gateway CLI device `operator.admin` scope — subagent spawning was blocked by a pending scope upgrade (`operator.read` → `operator.admin`); fixed in `devices/paired.json` + added `gateway.nodes.pairing.autoApproveCidrs: [127.0.0.0/8]` to auto-approve future upgrades from localhost |


## What's New in v3.11

| Area | Change |
|------|--------|
| **OOM crashes fixed** | Raised V8 heap limit from `--max-old-space-size=384` to `512` MB — the 384 MB ceiling caused 8 OOM crashes in one day whenever Henry spawned a Coder subagent (Henry + Coder together peaked at ~610 MB) |
| **systemd memory tuning** | `MemoryHigh` raised from 640 M to 700 M so systemd doesn't throttle Node.js GC before the hard limit is reached |
| **Session hygiene** | Old session transcript files pruned on the reference server; gateway now starts cleanly without replaying a large backlog of stale sessions |


## What's New in v3.12

| Area | Change |
|------|--------|
| **Delegation resilience** | Henry's `delegate-task.md` skill now retries `sessions_spawn` once after a 20-second wait if the first attempt fails — covers the window when the gateway is restarting after a crash |
| **Faster gateway recovery** | `RestartSec` reduced from 10 s to 3 s in the service file — gateway is back in ~11 s instead of ~18 s after a crash, reducing the chance of a subagent announce timeout |
| **Root-cause prevention** | v3.11 heap fix (384→512 MB) already prevents the OOM crash that caused the announce failure; v3.12 adds defence-in-depth for any future transient gateway drop |


## What's New in v3.50

| Area | Change |
|------|--------|
| **Announce timeout root cause fixed** | "Subagent announce failed: gateway timeout after 10000ms" traced to `readSubagentOutput` calling `chat.history` with no explicit timeout (defaults to 10 s hardcoded). Under memory pressure the gateway was missing this 10 s window. |
| **V8 heap raised** | `--max-old-space-size` increased 512 MB to 640 MB -- eliminates GC thrashing that caused >10 s response delays during dual-agent execution |
| **systemd limits raised** | `MemoryHigh` 700 M to 800 M, `MemoryMax` 800 M to 900 M -- stops kernel cgroup throttling when Henry + subagent peak at ~734 MB |


## How It Works

```
Your Phone / Computer
        │
        │  Telegram messages
        ▼
  @HenryBot  @CoderBot  @ScoutBot  @WriterBot  @WatcherBot
        │
        │  HTTPS (Telegram Bot API)
        ▼
DigitalOcean Droplet — Ubuntu 24.04 — $6/month
        │
        │  OpenClaw Gateway (port 18789, systemd service)
        ├── Henry workspace  (Claude Sonnet 4.6)
        ├── Coder workspace  (Claude Sonnet 4.6)
        ├── Scout workspace  (Claude Haiku 4.5)
        ├── Writer workspace (Claude Sonnet 4.6)
        └── Watcher workspace (Claude Haiku 4.5)
        │
        ├── Anthropic API (Claude models)
        ├── Discord Webhook → #reports channel
        └── Shiny Dashboard (port 8050, public)
```

**Data flow for every Telegram message (text or voice):**

1. User sends a message or voice note to a bot (e.g., @HenryBot)
2. If a voice note: OpenClaw downloads the audio and transcribes it via OpenAI (gpt-4o-mini-transcribe); transcript is echoed to the chat, then used as the user's command
3. Telegram delivers the text to the OpenClaw gateway via HTTPS
4. The routing engine matches the bot to the correct agent workspace
5. Agent loads its SOUL.md (system prompt) + memory context
6. OpenClaw calls the Anthropic API with the Claude model assigned to that agent
7. Claude responds, optionally using tools (web search, shell, file ops, agent delegation)
8. Response is sent back to the user's Telegram chat
9. A signed, color-coded embed is posted to Discord `#reports`

---

## Repository Structure

```
ClawInc/
│
├── README.md                        ← This document
├── Student_Setup_Guide.md           ← Complete student setup guide (Markdown)
│
├── dashboard/                       ← Shiny for Python monitoring dashboard
│   ├── app.py                       ← Dashboard app (port 8050)
│   └── requirements.txt             ← Python dependencies
│
└── deploy/                          ← All server installation files
    ├── README.md                    ← Deploy quick-start
    ├── deploy-openclaw.sh           ← Main deployment script
    ├── openclaw.service             ← Systemd unit (OpenClaw gateway)
    ├── clawinc-dashboard.service    ← Systemd unit (Shiny dashboard)
    └── configs/
        ├── openclaw.json            ← Master gateway config (template)
        ├── workspace-henry/
        │   ├── SOUL.md              ← Henry's system prompt / personality
        │   ├── AGENTS.md            ← Henry's knowledge of the other agents
        │   ├── MEMORY.md            ← Henry's persistent memory bootstrap
        │   └── skills/
        │       ├── delegate-task/SKILL.md
        │       ├── daily-standup/SKILL.md
        │       ├── discord-report/SKILL.md
        │       └── rnd-meeting/SKILL.md
        ├── workspace-coder/
        │   ├── SOUL.md
        │   ├── AGENTS.md
        │   ├── MEMORY.md
        │   └── skills/
        │       ├── vibe-code/SKILL.md
        │       ├── debug-app/SKILL.md
        │       ├── deploy-app/SKILL.md
        │       └── discord-report/SKILL.md
        ├── workspace-scout/
        │   ├── SOUL.md
        │   ├── AGENTS.md
        │   ├── MEMORY.md
        │   └── skills/
        │       ├── web-research/SKILL.md
        │       ├── trend-monitor/SKILL.md
        │       ├── news-digest/SKILL.md
        │       └── discord-report/SKILL.md
        ├── workspace-writer/
        │   ├── SOUL.md
        │   ├── AGENTS.md
        │   ├── MEMORY.md
        │   └── skills/
        │       ├── write-memo/SKILL.md
        │       ├── write-report/SKILL.md
        │       ├── content-plan/SKILL.md
        │       └── discord-report/SKILL.md
        └── workspace-watcher/
            ├── SOUL.md
            ├── AGENTS.md
            ├── MEMORY.md
            ├── HEARTBEAT.md
            └── skills/
                ├── health-check/SKILL.md
                ├── log-analyzer/SKILL.md
                ├── session-cleanup/SKILL.md
                └── discord-report/SKILL.md
```

---

## The Five Agents

### Henry — Chief of Staff
- **Model:** `anthropic/claude-opus-4-7` (highest intelligence)
- **Telegram:** @YourHenryBot
- **Role:** Primary user interface. Receives high-level goals, delegates to other agents. Has agent-to-agent delegation authority over all four others.
- **Skills:** `delegate-task`, `daily-standup`, `rnd-meeting`, `discord-report`
- **Cron:** Nightly R&D synthesis session (11 PM)
- **Discord:** Posts after every user prompt and every nightly session (gold embed)

### Coder — Software Engineer
- **Model:** `anthropic/claude-sonnet-4-6`
- **Telegram:** @YourCoderBot
- **Role:** Writes, debugs, and executes code. Handles Python/R data analysis, statistical modeling, and automation scripts.
- **Skills:** `vibe-code`, `debug-app`, `deploy-app`, `discord-report`
- **Cron:** Overnight development work queue (2 AM)
- **Discord:** Posts after every user prompt and every development task (blue embed)

### Scout — Research Analyst
- **Model:** `anthropic/claude-haiku-4-5-20251001` (fast, cost-efficient for web research)
- **Telegram:** @YourScoutBot
- **Role:** Web research, trend monitoring, news aggregation, competitive intelligence.
- **Skills:** `web-research`, `trend-monitor`, `news-digest`, `discord-report`
- **Cron:** Morning research scan (8 AM)
- **Discord:** Posts after every user prompt and every morning scan (green embed)

### Writer — Content Creator
- **Model:** `anthropic/claude-sonnet-4-6`
- **Telegram:** @YourWriterBot
- **Role:** Produces polished written output: executive memos, research reports, marketing content, summaries.
- **Skills:** `write-memo`, `write-report`, `content-plan`, `discord-report`
- **Cron:** Daily morning memo compilation (9 AM)
- **Discord:** Posts after every user prompt and every written deliverable (purple embed)

### Watcher — System Monitor
- **Model:** `anthropic/claude-haiku-4-5-20251001`
- **Telegram:** @YourWatcherBot
- **Role:** Health monitoring. Checks server resources, log anomalies, and agent responsiveness. Alerts Henry on issues. Reachable directly via Telegram for on-demand health queries.
- **Skills:** `health-check`, `log-analyzer`, `session-cleanup`, `discord-report`
- **Cron:** Every 30 minutes (health check) + Sunday 4 AM (weekly cleanup)
- **Discord:** Posts after every user prompt and when alert thresholds exceeded (orange embed)

---

## Discord Integration

Every agent has a `discord-report` skill and is configured to post to the ClawInc Discord `#reports` channel after:

1. **Every Telegram response** — a signed summary of what was done
2. **Every scheduled cron job** — a report of the automated task output

Agents are color-coded in Discord: Henry (gold), Coder (blue), Scout (green), Writer (purple), Watcher (orange).

**Setup:** Create a Discord server → `#reports` channel → webhook → paste the webhook URL as `DISCORD_WEBHOOK_URL` in the deploy script. Full instructions in [Student_Setup_Guide.md](Student_Setup_Guide.md).

---

## Cron Schedule

| Time | Agent | Task | Discord |
|------|-------|------|---------|
| Every 30 min | Watcher | System health check | Only on alerts |
| 8:00 AM daily | Scout | Web research scan | Always |
| 9:00 AM daily | Writer | Morning intelligence memo | Always |
| 11:00 PM daily | Henry | Nightly R&D strategy session | Always |
| 2:00 AM daily | Coder | Process queued dev tasks | Always |
| 4:00 AM Sundays | Watcher | Weekly session cleanup | Always |

---

## Technology Stack

| Component | Technology |
|-----------|-----------|
| Agent runtime | OpenClaw 2026.4.24 |
| AI models | Anthropic Claude (Opus 4.7, Sonnet 4.6, Haiku 4.5) |
| Voice transcription | OpenAI gpt-4o-mini-transcribe (Whisper API) |
| Server | Ubuntu 24.04 on DigitalOcean ($6/month) |
| Runtime | Node.js 24 |
| Process management | systemd |
| Messaging | Telegram Bot API (text + voice notes) |
| Reporting | Discord webhooks → #reports |
| Memory | QMD vector + full-text hybrid search |
| Monitoring dashboard | Shiny for Python (port 8050, public) |

---

## OpenClaw Configuration Notes

The master config is `deploy/configs/openclaw.json`. OpenClaw 2026.x uses strict JSON schema validation — the gateway refuses to start if any unrecognized key is present.

**Key schema facts for 2026.x:**
- API key goes in `env.ANTHROPIC_API_KEY` (not `providers.anthropic.apiKey`)
- Discord webhook goes in `env.DISCORD_WEBHOOK_URL`
- `channels.telegram.accounts` is an **object** keyed by account ID (not an array)
- Bot token field is `botToken` (not `token`)
- `gateway.mode` is the correct key (not `gateway.authToken`)
- Exec approvals require **two settings**: `tools.exec.security: "full"` in openclaw.json AND `defaults.security: "full"` in exec-approvals.json
- The `execApprovals.mode` and `tools.exec.askFallback` keys do not exist in 2026.x — omit them

**Known good config structure:**
```json
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-ant-api03-...",
    "DISCORD_WEBHOOK_URL": "https://discord.com/api/webhooks/..."
  },
  "gateway": { "mode": "local" },
  "tools": { "exec": { "security": "full", "ask": "off" } },
  "agents": { ... },
  "channels": { "telegram": { ... } },
  "approvals": { "exec": { "enabled": false } }
}
```

**exec-approvals.json** (written automatically by the installer):
```json
{
  "defaults": { "security": "full", "ask": "off" },
  "agents": { "*": { "security": "full", "ask": "off" } }
}
```

---

## Quick Deploy

```bash
# 1. Copy deploy package to your server
scp -r deploy/ root@YOUR_IP:/root/deploy/

# 2. SSH in and run — the script asks for credentials interactively
ssh root@YOUR_IP
chmod +x /root/deploy/deploy-openclaw.sh
/root/deploy/deploy-openclaw.sh

# 3. Verify
su - clawuser -c "openclaw status"
```

Have ready: Anthropic API key, OpenAI API key (for voice), Discord webhook URL, 5 Telegram bot tokens.

Full walkthrough: **[Student_Setup_Guide.md](Student_Setup_Guide.md)**

---

## Troubleshooting

```bash
# Check service status
systemctl is-active openclaw

# View live logs
journalctl -u openclaw -f

# Validate config
su - clawuser -c "openclaw config validate"

# Check all agents and Telegram connections
su - clawuser -c "openclaw agents list --bindings"

# Run diagnostics
su - clawuser -c "openclaw doctor"

# Test Discord webhook
curl -X POST "YOUR_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content": "test from ClawInc"}'

# Check cron job status (requires ~90 s for JIT warmup on first run)
su - clawuser -c "timeout 120 openclaw cron list"

# Inspect cron run results directly (no CLI needed)
cat ~/.openclaw/cron/jobs-state.json

# Clear cron error backoff after fixing a jobs.json mistake
echo '{"version":1,"jobs":{}}' > ~/.openclaw/cron/jobs-state.json
systemctl restart openclaw
```

### Known issues on 1 GB DigitalOcean droplets (v2.00 fixes)

| Symptom | Root cause | Fix applied |
|---------|-----------|-------------|
| Gateway OOM-kills on startup | `ProtectSystem=strict` prevents writing to `/tmp/openclaw-1000`; process retries until killed | Removed `ProtectSystem` and `ProtectHome`; raised `MemoryMax` to 1200 M |
| Telegram extension fails to import | `openclaw` not symlinked inside `plugin-runtime-deps/*/node_modules` after npm update | `fix-openclaw-symlinks.sh` runs as `ExecStartPre` on every start |
| Cron jobs show `lastStatus: "error"` — `TypeError: Cannot read properties of undefined (reading 'startsWith')` | `sessionTarget` field missing from `jobs.json` | All jobs require `"sessionTarget": "isolated"` |
| Cron jobs show `lastStatus: "error"` — `Delivering to Telegram requires target <chatId>` | No `delivery` field → OpenClaw defaults to `announce` mode, looks for last chatId | All jobs require `"delivery": {"mode": "none"}` |
| `openclaw cron list` hangs for 60+ seconds then times out | `openclaw-cron` subprocess JIT-compiles the full Node.js runtime (~60 s) before connecting; default server-side WS handshake timeout (10 s) fires first | Added `OPENCLAW_HANDSHAKE_TIMEOUT_MS=120000` to service; use `--timeout 120000` or read `jobs-state.json` directly |
| `openclaw cron add` hangs during deploy | Same JIT issue — the CLI always races against a freshly started gateway | Replaced `openclaw cron add` calls with direct `jobs.json` file write |
| Gateway crashes ~46 s after startup with `CIAO PROBING CANCELLED` | `bonjour` mDNS plugin tries to advertise on datacenter LAN where mDNS is blocked; unhandled promise rejection kills Node.js | Disabled `bonjour`, `acpx`, `browser`, `device-pair`, `phone-control`, `talk-voice` plugins in `plugins.entries` — cloud servers only need `telegram` |

---

*MKT/IDS 518 · University of Illinois at Chicago · J. Christopher Westland*

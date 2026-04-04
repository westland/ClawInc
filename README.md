# ClawInc — OpenClaw Multi-Agent AI Company

**A deployable five-agent autonomous AI company for marketing analytics, research, and automation.**  
*MKT 518 · J. Christopher Westland · University of Illinois at Chicago*

[![Release](https://img.shields.io/github/v/release/westland/ClawInc)](https://github.com/westland/ClawInc/releases/tag/v0.90)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-2026.3.31-blue)](https://openclaw.dev)
[![Platform](https://img.shields.io/badge/platform-Ubuntu%2024.04-orange)](https://ubuntu.com)
[![Telegram](https://img.shields.io/badge/interface-Telegram-2CA5E0)](https://telegram.org)
[![Discord](https://img.shields.io/badge/reports-Discord-5865F2)](https://discord.com)

> **v0.90 Release Notes** — All 5 agents now deliver signed, color-coded reports to a Discord guild automatically via webhook. Each agent has a `discord-report` skill. Set `DISCORD_WEBHOOK_URL` in the deploy script or add it to `openclaw.json` on a running server. Student Setup Guide now includes step-by-step Discord server, channel, and webhook creation instructions. Previous: v0.79 (Discord skill framework), v0.78 (Watcher Telegram bot, automated dashboard, reactive loop fix).

---

## Table of Contents

1. [Concept and Motivation](#1-concept-and-motivation)
2. [System Architecture](#2-system-architecture)
3. [The Agent Roster](#3-the-agent-roster)
4. [Technology Stack](#4-technology-stack)
5. [Repository Structure](#5-repository-structure)
6. [OpenClaw Configuration — Schema Deep Dive](#6-openclaw-configuration--schema-deep-dive)
7. [The Deploy Script](#7-the-deploy-script)
8. [Systemd Service](#8-systemd-service)
9. [Telegram Integration](#9-telegram-integration)
10. [Agent Workspaces](#10-agent-workspaces)
11. [Cron Automation](#11-cron-automation)
12. [Memory System](#12-memory-system)
13. [Security Model](#13-security-model)
14. [Key Implementation Decisions](#14-key-implementation-decisions)
15. [Schema Fixes for OpenClaw 2026.x](#15-schema-fixes-for-openclaw-2026x)
16. [Deployment Walkthrough](#16-deployment-walkthrough)
17. [Class Usage Guide](#17-class-usage-guide)
18. [Shiny Monitoring Dashboard](#18-shiny-monitoring-dashboard)

---

## 1. Concept and Motivation

### From Chatbot to Autonomous Employee

Traditional AI tools like ChatGPT and Claude are *reactive*: they answer questions when asked. **OpenClaw** is *proactive*: it takes autonomous action. The distinction is the difference between a research assistant who answers your questions and a full employee who independently researches, writes, codes, monitors systems, and reports back — without constant supervision.

This project builds a five-agent autonomous AI company — **ClawInc** — that runs 24/7 on a \$6/month cloud server. You control it entirely through **Telegram** text and voice messages from any device. The agents collaborate: the Chief of Staff (Henry) orchestrates the others, delegating research to Scout, writing to Writer, coding to Coder, and system monitoring to Watcher.

### Why This Matters for Marketing

Modern marketing analytics requires constant intelligence gathering, trend monitoring, report writing, and iterative analysis. A properly configured agent army can:

- Monitor industry news and competitor activity continuously
- Compile daily briefings automatically every morning
- Write structured research reports on demand
- Run statistical analyses in Python or R
- Maintain a searchable memory of all findings across sessions

This project teaches students to **build and operate** such a system, not merely use one.

### Why OpenClaw Specifically

OpenClaw is open-source, self-hosted, and model-agnostic. You own your data, control your costs, and can configure every aspect of agent behavior. It natively supports:

- Multi-agent orchestration with agent-to-agent delegation
- Telegram, WhatsApp, Discord, Signal, and other messaging channels
- File operations, shell execution, and web research tools
- Persistent memory across sessions (QMD vector search)
- Scheduled cron jobs for fully autonomous operation
- A browser-based dashboard for monitoring and management

---

## 2. System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   Your Phone / Computer                         │
│                                                                 │
│   Telegram App  ──────────────────►  @HenryClawBot             │
│                                       @CoderClawBot             │
│                                       @ScoutClawBot             │
│                                       @WriterClawBot            │
│                                       @WatcherClawBot           │
└───────────────────────────┬─────────────────────────────────────┘
                            │  HTTPS (Telegram Bot API)
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│              DigitalOcean Droplet — 137.184.15.207              │
│              Ubuntu 24.04 · 1 vCPU · 1GB RAM · 2GB swap        │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              OpenClaw Gateway (port 18789)               │   │
│  │              Runs as: clawuser (systemd service)         │   │
│  │                                                          │   │
│  │   ┌──────────┐  ┌──────────┐  ┌──────────┐             │   │
│  │   │  Henry   │  │  Coder   │  │  Scout   │  ...        │   │
│  │   │ Opus 4.6 │  │ Sonnet   │  │  Haiku   │             │   │
│  │   │workspace │  │workspace │  │workspace │             │   │
│  │   └──────────┘  └──────────┘  └──────────┘             │   │
│  │                                                          │   │
│  │   Cron Scheduler · Memory (QMD) · Routing Engine        │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            │                                     │
│                            │  HTTPS                              │
│                            ▼                                     │
│              Anthropic API (Claude models)                       │
└─────────────────────────────────────────────────────────────────┘
                            ▲
                            │  SSH Tunnel (port 18789)
                            │
                 OpenClaw Control UI (admin)          Shiny Dashboard (monitoring)
              http://localhost:18789                  http://137.184.15.207:8050
              Token required · SSH tunnel             Public · no auth required
```

### Data Flow

1. User sends a Telegram message to a bot (e.g., @HenryClawBot)
2. Telegram's Bot API delivers the message to the OpenClaw gateway via HTTPS long-polling
3. The routing engine matches the incoming `accountId` (`henry-bot`) to the `henry` agent via the bindings table
4. The agent loads its workspace context (SOUL.md system prompt + memory)
5. OpenClaw sends the conversation to the Anthropic API (Claude model specified per agent)
6. Claude's response is streamed back, optionally triggering tool calls (shell, file ops, web search, agent-to-agent delegation)
7. The final response is delivered back to the user's Telegram chat
8. The session and any new memories are persisted to disk

---

## 3. The Agent Roster

Each agent is an isolated workspace with its own system prompt, memory, skills, and Claude model assignment. They are not separate processes — they share one gateway process — but each has a completely separate state directory, session history, and personality.

### Henry — Chief of Staff
- **Model:** `anthropic/claude-opus-4-6` (highest intelligence, extended thinking)
- **Telegram:** @HenryClawBot
- **Role:** Primary interface for the user. Receives high-level goals and breaks them into tasks for the other agents. Has agent-to-agent delegation authority over all four others.
- **Skills:** `delegate-task`, `daily-standup`, `rnd-meeting`
- **Cron:** Nightly R&D synthesis session (11 PM)
- **Thinking:** `high` — uses Claude's extended thinking for strategic planning

### Coder — Software Engineer
- **Model:** `anthropic/claude-sonnet-4-5-20250929`
- **Telegram:** @CoderClawBot
- **Role:** Writes, debugs, and executes code. Handles Python/R data analysis, statistical modeling, and automation scripts.
- **Skills:** `vibe-code`, `debug-app`, `deploy-app`
- **Cron:** Overnight development work queue (2 AM)
- **Thinking:** `high` — careful reasoning for code correctness

### Scout — Research Analyst
- **Model:** `anthropic/claude-haiku-4-5-20251001` (fast, cost-efficient for web browsing)
- **Telegram:** @ScoutClawBot
- **Role:** Web research, trend monitoring, news aggregation, competitive intelligence.
- **Skills:** `web-research`, `trend-monitor`, `news-digest`
- **Cron:** Morning research scan (8 AM)
- **Thinking:** `medium`

### Writer — Content Creator
- **Model:** `anthropic/claude-sonnet-4-5-20250929`
- **Telegram:** @WriterClawBot
- **Role:** Produces polished written output: executive memos, research reports, marketing content, summaries.
- **Skills:** `write-memo`, `write-report`, `content-plan`
- **Cron:** Daily morning memo compilation (9 AM)
- **Thinking:** `medium`

### Watcher — System Monitor
- **Model:** `anthropic/claude-haiku-4-5-20251001`
- **Telegram:** @WatcherClawBot
- **Role:** Background health monitoring. Checks server resources, log anomalies, and agent responsiveness. Reports to Henry on issues. Now reachable directly via Telegram for on-demand health queries.
- **Skills:** `health-check`, `log-analyzer`, `session-cleanup`
- **Cron:** Every 30 minutes (health check) + Sunday 4 AM (weekly cleanup)
- **Thinking:** `low` — efficiency optimized

---

## 4. Technology Stack

| Component | Technology | Why |
|-----------|-----------|-----|
| **Agent runtime** | OpenClaw 2026.3.31 | Open-source, self-hosted, model-agnostic agent framework |
| **AI models** | Anthropic Claude (Opus 4.6, Sonnet 4.5, Haiku 4.5) | Best reasoning, tool use, and instruction following at each price tier |
| **Server** | Ubuntu 24.04 on DigitalOcean | Cheap ($6/mo), reliable, simple SSH access |
| **Runtime** | Node.js 24 | OpenClaw's native runtime |
| **Process management** | systemd | Auto-restart on failure, runs at boot, resource limits |
| **Messaging** | Telegram Bot API | Free, reliable, works on all devices, supports voice notes |
| **Memory** | QMD (falls back to builtin) | Vector + full-text hybrid search across agent memories |
| **Control UI** | OpenClaw built-in (port 18789, SSH tunnel) | Chat with agents, session browser, config editor, log viewer |
| **Monitoring dashboard** | Shiny for Python (port 8050, public) | Agent status cards, CPU/RAM/disk gauges, live log tail, cron schedule |
| **Documentation** | R Markdown (Rmd → HTML/PDF) | Consistent with course toolchain |

---

## 5. Repository Structure

```
ClawInc/
│
├── README.md                              ← This document
├── Student_Setup_Guide_ClawInc.Rmd        ← Complete student setup guide
│                                            (knit to HTML in RStudio)
│
├── dashboard/                             ← Shiny for Python monitoring dashboard
│   ├── app.py                             ← Dashboard application (port 8050)
│   └── requirements.txt                  ← Python dependencies (shiny, psutil)
│
├── deploy/                                ← All server installation files
│   ├── README.md                          ← Deploy package quick-start
│   ├── deploy-openclaw.sh                 ← Main deployment script
│   ├── openclaw.service                   ← Systemd unit file (OpenClaw gateway)
│   ├── clawinc-dashboard.service          ← Systemd unit file (Shiny dashboard)
│   └── configs/
│       ├── openclaw.json                  ← Master gateway config (template)
│       ├── workspace-henry/
│       │   ├── SOUL.md                    ← Henry's system prompt / personality
│       │   ├── AGENTS.md                  ← Henry's knowledge of other agents
│       │   ├── MEMORY.md                  ← Henry's persistent memory bootstrap
│       │   └── skills/
│       │       ├── delegate-task/SKILL.md
│       │       ├── daily-standup/SKILL.md
│       │       └── rnd-meeting/SKILL.md
│       ├── workspace-coder/               ← (same structure)
│       ├── workspace-scout/               ← (same structure)
│       ├── workspace-writer/              ← (same structure)
│       └── workspace-watcher/
│           └── HEARTBEAT.md              ← Watcher's heartbeat prompt
│
├── FINAL-PROJECT_a_company_of_Clawbots.Rmd  ← Project description and concept
├── Making_a_company_of_Clawbots.Rmd         ← Agent design rationale
├── Final Project -- Market Bot Army.Rmd     ← Assignment specification
├── bot_army_grading.Rmd                     ← Grading rubric
├── The assignment.qmd                       ← Assignment in Quarto format
└── lecture_notes_for_mktbook_*.Rmd          ← Related course lecture notes
```

---

## 6. OpenClaw Configuration — Schema Deep Dive

The master configuration file is `deploy/configs/openclaw.json`. This is the most technically important file in the project. OpenClaw 2026.x uses **strict JSON schema validation** — the gateway refuses to start if a single unrecognized key is present.

### What Changed from Earlier Versions

OpenClaw 2026.x introduced a completely different schema from earlier releases. The original deployment was written against an older API and failed with 20+ validation errors. The key differences:

| Old Schema (pre-2026) | New Schema (2026.x) |
|----------------------|---------------------|
| `providers.anthropic.apiKey` | `env.ANTHROPIC_API_KEY` |
| `channels.telegram.accounts` as **array** | `channels.telegram.accounts` as **object** (keyed by ID) |
| `channels.telegram.accounts[].token` | `channels.telegram.accounts.<id>.botToken` |
| `gateway.authToken`, `gateway.host` | `gateway.mode`, `gateway.auth.token` |
| `agents.list[].tools` as array of strings | `agents.list[].tools` as object (deny/allow) |
| `agents.list[].thinking` | `agents.list[].thinkingDefault` |
| `agents.list[].systemPromptFile` | workspace `SOUL.md` (auto-loaded from workspace dir) |
| `automation.cron[]` array in JSON | `openclaw cron add` CLI commands |
| `memory.qmd.searchMode: "hybrid"` | must be `"query"` \| `"search"` \| `"vsearch"` |
| `ExecStart=openclaw gateway start` | `ExecStart=openclaw gateway run` |

### Annotated openclaw.json

```json
{
  // API key injected as environment variable — the correct 2026.x pattern.
  // Never put it in providers.* — that key no longer exists.
  "env": {
    "ANTHROPIC_API_KEY": "YOUR_ANTHROPIC_API_KEY"
  },

  // gateway.mode is REQUIRED in 2026.x. Without it the gateway aborts.
  // "local" = runs on loopback, accessible only via SSH tunnel (secure default).
  // "remote" = binds to LAN/tailnet (requires auth token).
  "gateway": {
    "mode": "local"
  },

  "agents": {
    // defaults apply to all agents unless overridden per-agent
    "defaults": {
      "model": { "primary": "anthropic/claude-sonnet-4-5-20250929" }
    },
    // agents.list replaces the old per-agent config blocks.
    // Only "id" is required; all other fields are optional overrides.
    "list": [
      {
        "id": "henry",
        "name": "Henry",
        "default": true,                         // handles unmatched traffic
        "workspace": "~/.openclaw/workspace-henry",
        "agentDir": "~/.openclaw/agents/henry",  // sessions + state stored here
        "model": "anthropic/claude-opus-4-6",    // per-agent model override
        "thinkingDefault": "high"                // extended thinking by default
      },
      // ... coder, scout, writer, watcher follow the same pattern
    ]
  },

  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "open",     // allow any Telegram user to DM the bot
      "allowFrom": ["*"],     // REQUIRED when dmPolicy="open" — explicit wildcard
      "defaultAccount": "henry-bot",
      // accounts is a RECORD (object), not an array.
      // Each key becomes the accountId used in bindings.
      "accounts": {
        "henry-bot": {
          "botToken": "YOUR_TELEGRAM_BOT_TOKEN_HENRY",
          "dmPolicy": "open",
          "allowFrom": ["*"]
        }
        // coder-bot, scout-bot, writer-bot follow the same pattern
      }
    }
  },

  // Bindings connect incoming messages to specific agents.
  // match.channel = which messaging platform
  // match.accountId = which bot token (maps to the accounts keys above)
  // agentId = which agent in agents.list handles this traffic
  "bindings": [
    { "agentId": "henry", "match": { "channel": "telegram", "accountId": "henry-bot" } },
    { "agentId": "coder", "match": { "channel": "telegram", "accountId": "coder-bot" } },
    { "agentId": "scout", "match": { "channel": "telegram", "accountId": "scout-bot" } },
    { "agentId": "writer", "match": { "channel": "telegram", "accountId": "writer-bot" } }
  ],

  // Memory backend. "qmd" uses vector+FTS hybrid search if the qmd binary
  // is installed; falls back to builtin full-text search automatically.
  // searchMode must be "query" | "search" | "vsearch" — not "hybrid" (old).
  "memory": {
    "backend": "qmd",
    "qmd": { "searchMode": "search" }
  },

  "logging": {
    "level": "info",
    "file": "~/.openclaw/logs/openclaw.log"
    // Note: "maxSize", "maxFiles", "console" are NOT valid in 2026.x
  },

  // cron.enabled activates the scheduler.
  // Individual jobs are NOT defined here — use "openclaw cron add" CLI.
  "cron": { "enabled": true }
}
```

### How the Schema Validation Works

OpenClaw parses `openclaw.json` with a [Zod](https://zod.dev)-based schema validator before starting the gateway. Any key not in the schema causes an immediate abort with error messages listing every violation. This is intentional — it prevents silent misconfiguration.

To validate without starting the gateway:
```bash
su - clawuser -c "openclaw config validate"
```

To see the full JSON Schema:
```bash
su - clawuser -c "openclaw config schema"
```

---

## 7. The Deploy Script

`deploy/deploy-openclaw.sh` is a single bash script that provisions a bare Ubuntu 24.04 server from zero to a running OpenClaw installation. It requires root and runs once.

### Phase 1 — Server Preparation

```bash
# Creates 2GB swap — critical for a 1GB RAM server.
# Without swap, Node.js npm installs and model loading will OOM-kill.
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
sysctl vm.swappiness=60

# Non-root service user with minimal sudo privileges
adduser --disabled-password clawuser
echo "clawuser ALL=(ALL) NOPASSWD: /bin/systemctl restart openclaw, \
      /bin/systemctl status openclaw, /bin/journalctl -u openclaw*" \
      > /etc/sudoers.d/openclaw

# Firewall: only SSH exposed publicly.
# The gateway binds to loopback; access via SSH tunnel only.
ufw default deny incoming
ufw allow ssh
ufw --force enable
```

**Why 2GB swap?** The 1GB RAM DigitalOcean droplet is tight for Node.js with multiple concurrent LLM sessions. Swap provides a buffer — it's slow but prevents crashes. The `swappiness=60` setting tunes the kernel to use swap moderately rather than aggressively.

**Why a non-root user?** Running the gateway as root is a significant security risk. A non-root `clawuser` limits blast radius if the agent is ever manipulated into executing malicious shell commands.

### Phase 2 — Installation

```bash
# NodeSource repository for Node.js 24 (LTS)
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
apt-get install -y nodejs

# OpenClaw installed globally via npm
npm install -g openclaw@latest
```

### Phase 3 — Configuration

The script copies the `configs/` directory to `/home/clawuser/.openclaw/` and uses `sed` to substitute API key placeholders:

```bash
sed -i "s|YOUR_ANTHROPIC_API_KEY|${ANTHROPIC_API_KEY}|g" "$CONFIG"
sed -i "s|YOUR_TELEGRAM_BOT_TOKEN_HENRY|${TELEGRAM_TOKEN_HENRY}|g"   "$CONFIG"
sed -i "s|YOUR_TELEGRAM_BOT_TOKEN_CODER|${TELEGRAM_TOKEN_CODER}|g"   "$CONFIG"
sed -i "s|YOUR_TELEGRAM_BOT_TOKEN_SCOUT|${TELEGRAM_TOKEN_SCOUT}|g"   "$CONFIG"
sed -i "s|YOUR_TELEGRAM_BOT_TOKEN_WRITER|${TELEGRAM_TOKEN_WRITER}|g" "$CONFIG"
sed -i "s|YOUR_TELEGRAM_BOT_TOKEN_WATCHER|${TELEGRAM_TOKEN_WATCHER}|g" "$CONFIG"
```

Set all five variables at the top of `deploy-openclaw.sh` before running:
```bash
ANTHROPIC_API_KEY="sk-ant-..."
TELEGRAM_TOKEN_HENRY="..."
TELEGRAM_TOKEN_CODER="..."
TELEGRAM_TOKEN_SCOUT="..."
TELEGRAM_TOKEN_WRITER="..."
TELEGRAM_TOKEN_WATCHER="..."
```

**Note:** After deploying, the `openclaw.json` must be replaced with the corrected 2026.x schema version (see [Section 15](#15-schema-fixes-for-openclaw-2026x)). The deploy script generates a config against the old schema.

### Phase 5 — Dashboard Deployment

The deploy script now automatically installs and enables the Shiny monitoring dashboard:

```bash
# Phase 5 (phase5_dashboard) — runs at the end of deploy-openclaw.sh
apt-get install -y python3.12-venv
python3 -m venv /opt/clawinc-dashboard/venv
/opt/clawinc-dashboard/venv/bin/pip install shiny psutil
cp dashboard/app.py /opt/clawinc-dashboard/
cp deploy/clawinc-dashboard.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now clawinc-dashboard
ufw allow 8050/tcp
```

After the deploy script completes, the dashboard is immediately accessible at `http://YOUR_IP:8050` — no SSH tunnel required.

### Phase 7 — Security Hardening

```bash
# All config files: owner read/write only
find "${OPENCLAW_DIR}" -type d -exec chmod 700 {} \;
find "${OPENCLAW_DIR}" -type f -exec chmod 600 {} \;
chmod 600 "${OPENCLAW_DIR}/openclaw.json"
```

This ensures API keys and bot tokens on disk are readable only by `clawuser`.

---

## 8. Systemd Service

The gateway runs as a systemd service so it starts automatically at boot and restarts on failure.

### Unit File (`deploy/openclaw.service`)

```ini
[Unit]
Description=OpenClaw AI Agent Gateway — ClawInc
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=clawuser
Group=clawuser
WorkingDirectory=/home/clawuser

# IMPORTANT: use "gateway run" (foreground), NOT "gateway start"
# "gateway start" in 2026.x tries to invoke OpenClaw's internal
# systemd user-service manager, which is unavailable without
# systemd --user. The gateway reports "Gateway service disabled."
# "gateway run" starts the gateway directly in the foreground,
# which is what a systemd service needs.
ExecStart=/usr/bin/openclaw gateway run

ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10

Environment=NODE_ENV=production
Environment=HOME=/home/clawuser
# Prevents extra startup overhead from OpenClaw's self-respawn mechanism
Environment=OPENCLAW_NO_RESPAWN=1

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=false           # must be false — clawuser's home is the data dir
ReadWritePaths=/home/clawuser/.openclaw /tmp/openclaw /tmp/openclaw-1000

# IMPORTANT: PrivateTmp=false (changed from original true)
# PrivateTmp=true creates an isolated /tmp namespace. OpenClaw creates
# /tmp/openclaw-{uid} for its lock file. With PrivateTmp=true the
# directory exists in the private namespace but Node.js cannot create it
# because the parent path resolution fails. Setting false uses real /tmp.
PrivateTmp=false

MemoryMax=512M
MemoryHigh=384M
TasksMax=64
StandardOutput=journal
StandardError=journal
SyslogIdentifier=openclaw

[Install]
WantedBy=multi-user.target
```

### Service Management

```bash
systemctl daemon-reload          # reload unit file after changes
systemctl enable openclaw        # start at boot
systemctl start openclaw         # start now
systemctl restart openclaw       # apply config changes
systemctl status openclaw        # check health
journalctl -u openclaw -f        # tail logs in real time
```

---

## 9. Telegram Integration

### How OpenClaw Connects to Telegram

OpenClaw uses [grammY](https://grammy.dev), a TypeScript Telegram Bot framework, running inside the gateway process. It uses **long polling** by default: the gateway makes repeated HTTPS requests to `api.telegram.org/bot{TOKEN}/getUpdates` and processes incoming messages.

This means:
- No webhook setup required
- No public inbound port needed (all outbound HTTPS)
- Works immediately behind the firewall

### Multi-Account Architecture

A single OpenClaw gateway can run multiple Telegram bots simultaneously, each connected to a different agent. In the config:

```json
"channels": {
  "telegram": {
    "accounts": {
      "henry-bot":   { "botToken": "TOKEN_A" },
      "coder-bot":   { "botToken": "TOKEN_B" },
      "scout-bot":   { "botToken": "TOKEN_C" },
      "writer-bot":  { "botToken": "TOKEN_D" },
      "watcher-bot": { "botToken": "TOKEN_E" }
    }
  }
}
```

The gateway opens five separate long-polling connections in parallel. The routing engine maps each `accountId` to an agent via the `bindings` array.

### Message Routing

```
Incoming Telegram message
    → Which bot received it? (accountId from grammY context)
    → Look up binding: {channel: "telegram", accountId: "henry-bot"}
    → Route to agent: "henry"
    → Load henry's workspace context + session history
    → Call Anthropic API with henry's system prompt
    → Return response to the originating Telegram chat
```

### DM Policy

`dmPolicy: "open"` with `allowFrom: ["*"]` means any Telegram user can message the bots. This is appropriate for a class project with trusted users.

For production or sensitive deployments, use `dmPolicy: "allowlist"` with specific Telegram user IDs:
```json
"allowFrom": [123456789, 987654321]
```

Or `dmPolicy: "pairing"` which requires users to exchange a pairing code before first use.

---

## 10. Agent Workspaces

Each agent's workspace is a directory at `~/.openclaw/workspace-{agentname}/`. It is the agent's "desk" — everything defining who it is and what it knows.

### Directory Structure

```
workspace-henry/
├── SOUL.md          ← System prompt: personality, role, values, capabilities
├── AGENTS.md        ← Henry's directory of other agents and how to work with them
├── MEMORY.md        ← Bootstrap memories: standing instructions, context
├── memory/          ← Persistent memory files (written during operation)
└── skills/
    ├── delegate-task/
    │   └── SKILL.md ← Slash command: /delegate-task
    ├── daily-standup/
    │   └── SKILL.md ← Slash command: /daily-standup
    └── rnd-meeting/
        └── SKILL.md ← Slash command: /rnd-meeting
```

### SOUL.md — The System Prompt

`SOUL.md` is the most important file. It is prepended to every conversation as the system prompt. It defines:

- The agent's name, role, and personality
- Its responsibilities and areas of expertise
- How it should structure responses
- What tools it may use and when
- How it interacts with other agents

Example (Henry's SOUL.md excerpt):
```markdown
# Henry — Chief of Staff, ClawInc

You are Henry, the Chief of Staff and primary orchestrator of ClawInc,
an AI-powered marketing analytics company...

## Your Role
- Serve as the primary interface between the human operator and the agent team
- Receive high-level goals and decompose them into concrete tasks
- Delegate research to Scout, writing to Writer, development to Coder
- Synthesize outputs into actionable intelligence for the operator

## Communication Style
- Direct and professional. No unnecessary preamble.
- Use structured markdown in responses (headers, bullets, tables)
- Always confirm your understanding before delegating complex tasks
```

### AGENTS.md — Team Directory

This file gives each agent knowledge of the team structure:

```markdown
# ClawInc Agent Directory

## Coder
- Role: Software Engineer
- Contact: Message @CoderClawBot or use agent-to-agent delegation
- Capabilities: Python, R, data analysis, debugging, shell scripts

## Scout
- Role: Research Analyst
- Capabilities: Web search, trend monitoring, news aggregation
```

Henry uses this to know what to delegate and to whom.

### Skills

Skills are pre-built task templates activated by slash commands. A skill file is a Markdown prompt that the agent executes when triggered:

```markdown
<!-- workspace-henry/skills/delegate-task/SKILL.md -->
# /delegate-task

When invoked, you will receive a task description. You must:
1. Identify the most appropriate agent for the task
2. Frame the task clearly with context, deliverables, and deadline
3. Send the task via agent-to-agent messaging
4. Confirm receipt and set a check-in reminder
```

Users can trigger skills in Telegram with `/delegate-task summarize the Q1 trends`.

---

## 11. Cron Automation

Cron jobs are managed entirely through the `openclaw cron` CLI — they are **not** stored in `openclaw.json`. The cron scheduler is a component of the running gateway.

### Adding Jobs

```bash
openclaw cron add \
  --name "morning-research" \
  --agent "scout" \
  --cron "0 8 * * *" \          # standard 5-field cron expression
  --session isolated \           # each run gets a fresh session
  --message "Run your morning research routine..."
```

### Job Storage

Jobs are stored in a JSONL file at `~/.openclaw/agents/{agentId}/cron-jobs.jsonl`. Each job record includes the schedule, message payload, session mode, and run history.

### The Six Scheduled Jobs

| Name | Agent | Schedule | Purpose |
|------|-------|----------|---------|
| `morning-research` | Scout | `0 8 * * *` | Daily web scan for AI/marketing trends |
| `daily-memo` | Writer | `0 9 * * *` | Compile Scout's research into executive brief |
| `overnight-worker` | Coder | `0 2 * * *` | Process queued development tasks |
| `health-check` | Watcher | `*/30 * * * *` | Server health monitoring every 30 min |
| `nightly-rnd` | Henry | `0 23 * * *` | Orchestrate nightly R&D strategy session |
| `session-cleanup` | Watcher | `0 4 * * 0` | Weekly session archive and cleanup |

### Session Isolation

All jobs use `--session isolated`, which means each cron run gets a fresh conversation context with no history from previous runs. This prevents cron jobs from accumulating stale context over time. The agent still has access to its persistent memory files — only the live session is isolated.

### Monitoring Cron

```bash
# List all jobs with next run times
openclaw cron list

# View run history
openclaw cron runs

# Force a job to run immediately (testing)
openclaw cron run morning-research

# Disable without deleting
openclaw cron disable health-check
```

---

## 12. Memory System

OpenClaw's memory system allows agents to store and retrieve information across sessions. Without memory, each conversation starts blank — the agent has no recollection of previous research, decisions, or context.

### How Memory Works

When an agent stores a memory, it writes a Markdown file to `~/.openclaw/workspace-{agent}/memory/`. Each file is a dated entry. The memory system indexes these files for search.

Two backends are supported:

**`qmd` (preferred):** Hybrid vector + full-text search. Requires the `qmd` binary to be installed. Semantic search ("what did Scout find about TikTok trends?") and keyword search both work. Falls back to builtin automatically if `qmd` is not available.

**`builtin` (fallback):** Full-text search only. Less capable but zero-dependency. Automatically used when `qmd` binary is absent.

### Memory Configuration

```json
"memory": {
  "backend": "qmd",
  "qmd": {
    "searchMode": "search"
  }
}
```

`searchMode` valid values in 2026.x:
- `"query"` — natural language queries
- `"search"` — keyword/FTS search  
- `"vsearch"` — vector/semantic search

The old `"hybrid"` value was removed in 2026.x and causes a validation error.

### Cross-Agent Memory

Henry can search Scout's memory and vice versa. This is how the morning memo workflow functions:

1. Scout runs at 8 AM, researches trends, and stores findings in `workspace-scout/memory/2026-04-01-research.md`
2. Writer runs at 9 AM, searches Scout's memory for today's research, compiles the memo

This cross-agent memory access is controlled at the routing layer — agents cannot read each other's memories unless allowed.

---

## 13. Security Model

### Network Security

- **Firewall:** UFW allows SSH (port 22) and the Shiny dashboard (port 8050) inbound. The OpenClaw gateway is not publicly exposed.
- **Gateway binding:** OpenClaw listens on `127.0.0.1:18789` (loopback only). Even if the firewall were misconfigured, the gateway is unreachable from outside.
- **OpenClaw Control UI:** Only via SSH tunnel — `ssh -L 18789:localhost:18789 root@SERVER_IP` — then open the tokenized URL. The gateway auth token (`gateway.auth.token` in `openclaw.json`) is required to connect; the tokenized URL embeds it automatically.
- **Shiny dashboard:** Publicly accessible on port 8050. It is read-only — it reads logs and config files but cannot send commands to agents or modify any state.
- **Telegram:** All communication is outbound HTTPS to Telegram's servers. No inbound connections required.

### Process Security

- Gateway runs as `clawuser`, not root
- `NoNewPrivileges=true` — cannot escalate privileges
- `ProtectSystem=strict` — system directories are read-only
- `MemoryMax=512M` — prevents runaway memory consumption
- `TasksMax=64` — limits process spawning

### Credential Security

- API keys stored in `openclaw.json` with `chmod 600` (owner read-only)
- `PW-keys-etc.txt` listed in `.gitignore` — never committed to version control
- All tokens replaced with `YOUR_*` placeholders in the public repository

### Agent Tool Restrictions

Shell commands available to agents are defined in the `tools.shell.allowedCommands` config. Dangerous commands (`reboot`, `shutdown`, `dd`, `mkfs`) are explicitly blocked. Write access is limited to the agent's own workspace and `/tmp/openclaw/`.

---

## 14. Key Implementation Decisions

### Why DigitalOcean Over AWS/GCP?

DigitalOcean's pricing is predictable (\$6/month flat) with no surprise bills from data transfer or API calls. Students can set a firm spending cap. The interface is simpler for students new to cloud infrastructure, and the "Droplet Console" browser SSH feature eliminates the need for local SSH client setup for initial access.

### Why Not Run Locally?

The assignment requires agents to be available 24/7 to respond to Telegram messages and run scheduled cron jobs. A laptop in sleep mode or a home connection with dynamic IP cannot reliably maintain Telegram long polling. A \$6 VPS solves this cleanly.

### Why One Gateway, Not Five Processes?

OpenClaw's architecture runs all agents inside a single gateway process. This is more memory-efficient than five separate processes — critical on a 1GB RAM server. Agents are isolated at the application layer (separate workspaces, sessions, and memory), not the OS layer.

### Why Telegram?

Telegram was chosen over WhatsApp or iMessage because:
1. The Bot API is completely free with no rate limits for normal use
2. BotFather makes bot creation trivial (5 minutes)
3. It works on all platforms: iOS, Android, Windows, Mac, Linux, and browser
4. Voice note transcription is built-in
5. Group chats with multiple bots work natively
6. No phone number exposure — bots communicate via usernames

### Why Separate Models Per Agent?

Cost and performance trade-offs:
- **Henry** uses Claude Opus 4.6 (most expensive, most capable) because orchestration requires the highest reasoning quality — bad delegation decisions multiply errors across the whole system
- **Coder and Writer** use Sonnet 4.5 — strong performance for structured output at ~5x lower cost than Opus
- **Scout and Watcher** use Haiku 4.5 — fast and cheap for high-frequency tasks (Scout runs every morning; Watcher runs every 30 minutes)

Running all agents on Opus would cost ~5x more with negligible quality improvement for routine tasks.

### Why `--session isolated` for Cron Jobs?

Each cron run starting fresh prevents the "context pollution" problem: if Scout's 8 AM run accumulates a conversation about TikTok trends, the next day's 8 AM run would start mid-conversation with irrelevant context. Isolated sessions also prevent memory leakage between daily runs. Persistent memory (the `memory/` directory) is still available — only the live session context is isolated.

---

## 15. Schema Fixes for OpenClaw 2026.x

This section documents every change made to fix the 20+ schema validation errors that prevented the original deployment from starting.

### Error: `<root>: Unrecognized keys: "version", "instance", "providers", "automation", "security"`

**Fix:** Remove all these top-level keys. They were invented for the old schema.
- `version` → not needed
- `instance` → not needed  
- `providers.anthropic.apiKey` → move to `env.ANTHROPIC_API_KEY`
- `automation.cron[]` → add jobs via `openclaw cron add` CLI
- `security` → not a config key in 2026.x

### Error: `channels.telegram.accounts: Invalid input: expected record, received array`

**Fix:** Change `accounts` from a JSON array (`[{...}, {...}]`) to a JSON object (`{"henry-bot": {...}, "coder-bot": {...}}`).

```json
// WRONG (old)
"accounts": [
  { "id": "henry-bot", "token": "..." }
]

// CORRECT (2026.x)
"accounts": {
  "henry-bot": { "botToken": "..." }
}
```

### Error: `channels.telegram.allowFrom: dmPolicy="open" requires allowFrom to include "*"`

**Fix:** Add `"allowFrom": ["*"]` at both the top-level telegram config and inside each account object.

### Error: `gateway: Unrecognized keys: "host", "authToken", "cors", "rateLimit"`

**Fix:** Replace with `"mode": "local"`. The gateway.host is now controlled by `gateway.bind`. Auth is now `gateway.auth.token`. CORS and rate limiting are managed differently.

### Error: `agents.list.*.tools: Invalid input: expected object, received array`

**Fix:** The `tools` field per agent is now an object with `allow`/`deny` arrays, not a flat string array. Since we rely on defaults for most tools, simply remove the `tools` key from agent definitions.

### Error: `agents.list.*: Unrecognized keys: "role", "provider", "thinking", "maxTokens", "temperature", "systemPromptFile", "canDelegate", "reportsTo"`

**Fix:** Remove all these keys. Map:
- `"thinking": "high"` → `"thinkingDefault": "high"`
- `systemPromptFile` → not needed; OpenClaw auto-loads `SOUL.md` from the workspace
- `role`, `provider`, `canDelegate`, `reportsTo` → no equivalent; behavior is controlled via SOUL.md and agent-to-agent config

### Error: `memory.qmd.searchMode: Invalid input (allowed: "query", "search", "vsearch")`

**Fix:** Change `"searchMode": "hybrid"` to `"searchMode": "search"`.

### Error: `logging: Unrecognized keys: "maxSize", "maxFiles", "console"`

**Fix:** Remove these keys. The valid `logging` keys in 2026.x are: `level`, `file`, `maxFileBytes`, `consoleLevel`, `consoleStyle`, `redactSensitive`, `redactPatterns`.

### Error: `bindings.N: Invalid input`

**Fix:** Each binding needs `agentId` (not `agent`) and `match.channel` (required). The `account` field is now `match.accountId`.

```json
// WRONG (old)
{ "channel": "telegram", "account": "henry-bot", "agent": "henry" }

// CORRECT (2026.x)
{ "agentId": "henry", "match": { "channel": "telegram", "accountId": "henry-bot" } }
```

### Runtime Error: `Gateway failed to start: ENOENT: mkdir '/tmp/openclaw-1000'`

**Fix:** Two changes to the systemd service:

1. Change `PrivateTmp=true` to `PrivateTmp=false`. With `PrivateTmp=true`, systemd creates an isolated `/tmp` namespace. OpenClaw tries to create `/tmp/openclaw-{uid}` for its lock file, but the path resolution fails in the isolated namespace under the specific conditions of this service configuration.

2. Pre-create the directory:
   ```bash
   mkdir -p /tmp/openclaw-1000
   chown clawuser:clawuser /tmp/openclaw-1000
   ```

### Runtime Error: `Gateway service disabled` / `Start with: openclaw gateway`

**Fix:** The systemd service `ExecStart` was `openclaw gateway start`. In OpenClaw 2026.x, `openclaw gateway start` invokes OpenClaw's *internal* service manager (it tries to use `systemctl --user start openclaw-gateway.service`). This fails because user systemd is not available in this environment.

The correct command for running the gateway directly in the foreground (which is what a systemd `Type=simple` service needs) is `openclaw gateway run`.

---

## 16. Deployment Walkthrough

A complete end-to-end deployment takes approximately 15–20 minutes.

```
Time  Action
0:00  SSH into fresh Ubuntu 24.04 droplet as root
0:02  scp -r deploy/ root@YOUR_IP:/root/deploy/
0:03  nano /root/deploy/deploy-openclaw.sh  (fill in API keys)
0:05  chmod +x /root/deploy/deploy-openclaw.sh && ./deploy-openclaw.sh
      [script runs: ~8 minutes for apt updates + npm install]
0:13  Replace openclaw.json with corrected 2026.x schema template
0:14  Fill in API keys and bot tokens in the new config
0:15  openclaw config validate  → "Config valid"
0:16  Apply systemd fixes (2 sed commands + mkdir)
0:17  systemctl daemon-reload && systemctl restart openclaw
0:18  systemctl is-active openclaw  → "active"
0:19  Add 6 cron jobs via openclaw cron add CLI
0:20  Open Telegram, message Henry bot, receive response ✓
```

---

## 17. Class Usage Guide

### Controlling Your Agents

Send messages directly to each bot's Telegram username. Be specific — agents respond best to clear, structured requests.

**Example prompts:**

```
To Henry:
"Research Q1 2026 trends in influencer marketing, have Scout do the web
analysis, and ask Writer to produce a 2-page brief. Send it to me when done."

To Scout:
"Find the 5 most-cited academic papers on customer lifetime value published
in the last 2 years. Summarize key findings with citations."

To Coder:
"I'm attaching a CSV of website traffic data. Run a regression to identify
which traffic sources correlate with conversions. Show me the Python code
and output."

To Writer:
"Draft an executive memo on our Q1 marketing performance. Use this structure:
Executive Summary, Key Metrics, Top 3 Findings, 2 Recommendations. 400 words."
```

### Voice Commands — Verbal Orders

You can speak commands instead of typing, but voice transcription requires **Telegram Premium**.

**With Telegram Premium:** Hold the **microphone icon**, speak, release to send — the voice note is transcribed and delivered to the agent as text.

**Without Telegram Premium (free accounts):** Type commands as text. Agents respond identically to typed and transcribed input.

**Best practice:** Direct voice commands at Henry. As Chief of Staff, Henry can decompose a spoken instruction and delegate to multiple agents in one step. Example:

> *"Henry, have Scout research the latest trends in influencer marketing and have Writer turn the findings into a one-page executive brief. Post both to Discord when done."*

> **Important:** Use **voice notes** (press-and-hold the mic), not voice calls. Voice calls bypass the bot entirely. Voice notes only work with Telegram Premium.

### Checking What Agents Have Learned

```bash
# Search Henry's memory for past decisions
openclaw memory search "marketing strategy" --agent henry

# See Scout's recent research files
ls ~/.openclaw/workspace-scout/memory/
```

### Accessing the Dashboards

**Shiny Monitoring Dashboard** — open directly in any browser, no setup:
```
http://YOUR_DROPLET_IP:8050
```
Shows: agent cards, CPU/RAM/disk gauges, Telegram bot bindings, cron schedule, live log tail. Auto-refreshes every 30 seconds.

**OpenClaw Control UI** — requires SSH tunnel (admin use):
```bash
# Step 1 — open the tunnel on your local machine
ssh -N -L 18789:127.0.0.1:18789 root@YOUR_DROPLET_IP

# Step 2 — get the tokenized URL from the server
sudo -u clawuser openclaw dashboard
# Outputs: http://localhost:18789/#token=<your-token>

# Step 3 — open that URL in your browser
```
The Control UI lets you chat with agents directly, browse session history, edit agent workspaces, and view real-time logs.

---

## 18. Shiny Monitoring Dashboard

The repository includes a purpose-built monitoring dashboard (`dashboard/app.py`) built with [Shiny for Python](https://shiny.posit.co/py/). It runs as a separate systemd service on port 8050 and is publicly accessible without authentication.

### What It Shows

| Panel | Data source | Notes |
|-------|-------------|-------|
| Gateway Service | `systemctl is-active openclaw` | Green = active, red = down |
| CPU | `psutil.cpu_percent()` | Live percentage with color bar |
| RAM | `psutil.virtual_memory()` | Used / total GB + bar |
| Disk | `psutil.disk_usage('/')` | Used / total GB + bar |
| Process Info | `psutil.process_iter()` | Gateway PID, uptime, RSS memory |
| Telegram Bots | `openclaw.json` accounts + bindings | Shows account → agent routing |
| Agent Cards | `openclaw.json` agents list + workspace dirs | Model, thinking level, workspace init state |
| Cron Jobs | `openclaw cron list` | Schedule, last run, next run, status |
| Activity Log | `~/.openclaw/logs/openclaw.log` | Last 60 lines, auto-scrolled |

Auto-refreshes every 30 seconds. Manual **Refresh Now** button for immediate update.

### Architecture

```
Browser (any device)
    ↓ HTTP port 8050
Shiny for Python (uvicorn)
    ├── reads /home/clawuser/.openclaw/openclaw.json
    ├── reads /home/clawuser/.openclaw/logs/openclaw.log
    ├── reads /home/clawuser/.openclaw/workspace-*/
    ├── subprocess: systemctl is-active openclaw
    ├── subprocess: openclaw cron list
    └── psutil: CPU, RAM, disk, process list
```

The dashboard is **read-only** — it observes but does not control. API keys and bot tokens in the config are never exposed in the UI.

### Deployment

The dashboard is deployed automatically by `deploy-openclaw.sh` as part of **Phase 5 (phase5_dashboard)**. No manual installation is required on a fresh server — after the deploy script completes, the dashboard is immediately accessible at `http://YOUR_IP:8050` with no SSH tunnel required.

The dashboard runs as `/etc/systemd/system/clawinc-dashboard.service` using a Python venv at `/opt/clawinc-dashboard/venv/`.

```bash
# Manual install only needed if skipping the deploy script
apt-get install -y python3.12-venv
python3 -m venv /opt/clawinc-dashboard/venv
/opt/clawinc-dashboard/venv/bin/pip install shiny psutil
cp dashboard/app.py /opt/clawinc-dashboard/
cp deploy/clawinc-dashboard.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now clawinc-dashboard
ufw allow 8050/tcp
```

### Bug Fixes in v0.78

**Reactive loop fix:** Earlier versions had a bug where the Shiny reactive graph caused `openclaw cron list` (a subprocess call) to execute every 3 seconds as Shiny continuously re-evaluated reactive dependencies. This was fixed by wrapping the cron data fetch in `reactive.isolate()`, so the subprocess only runs on explicit refresh triggers, not on every reactive invalidation.

**Cron data caching:** Cron job data is now cached for 5 minutes. This prevents subprocess pile-up on slower servers where `openclaw cron list` may take 1–2 seconds to return, which previously caused queued subprocesses to accumulate during the 30-second auto-refresh cycle.

```bash
# Service management
systemctl status clawinc-dashboard
systemctl restart clawinc-dashboard
journalctl -u clawinc-dashboard -f
```

### OpenClaw Control UI vs. Shiny Dashboard

| | Shiny Dashboard | OpenClaw Control UI |
|--|-----------------|---------------------|
| **URL** | `http://IP:8050` | `http://localhost:18789/#token=...` |
| **Access** | Public, no auth | SSH tunnel + gateway token |
| **Purpose** | Read-only monitoring | Full admin control |
| **Chat with agents** | No | Yes |
| **Edit config** | No | Yes |
| **View sessions** | No | Yes |
| **Best for** | Students checking bot status | Instructor/admin operations |

### Gateway Token for Control UI

OpenClaw's built-in dashboard requires a gateway auth token. To get the tokenized URL:

```bash
# On the server
sudo -u clawuser openclaw dashboard
# Outputs: http://localhost:18789/#token=<token>
```

The token is stored in `~/.openclaw/openclaw.json` under `gateway.auth.token`. It is stable across restarts. The CLI also uses it via `gateway.remote.token` (set to the same value) so commands like `openclaw cron list` work without manually specifying a token.

---

## Contributing

This is a course project repository. Students are welcome to fork, customize their agent workspaces, and extend the deployment with additional agents or capabilities.

**To add a new agent:**
```bash
# Add workspace directory and SOUL.md
mkdir -p ~/.openclaw/workspace-myagent
echo "# MyAgent\nYou are..." > ~/.openclaw/workspace-myagent/SOUL.md

# Register in openclaw.json agents.list, then add a Telegram bot and binding

# Or use the CLI:
openclaw agents add --name "MyAgent" \
  --workspace ~/.openclaw/workspace-myagent \
  --model anthropic/claude-sonnet-4-6 \
  --bind telegram:myagent-bot
```

---

## License

MIT License — free to use, modify, and distribute.

---

*Built with [OpenClaw](https://openclaw.dev) · Deployed on [DigitalOcean](https://digitalocean.com) · Powered by [Anthropic Claude](https://anthropic.com)*

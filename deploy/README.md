# ClawInc — OpenClaw Deployment Package v1.61

Everything needed to install ClawInc on a fresh Ubuntu 24.04 DigitalOcean droplet.

---

## Quick Start

### 1. Upload this folder to your server

**Mac/Linux:**
```bash
scp -r deploy/ root@YOUR_DROPLET_IP:/root/deploy/
```

**Windows:** Use [WinSCP](https://winscp.net) (SCP, port 22) to copy the `deploy/` folder to `/root/deploy/` on the server.

### 2. SSH in and run the installer

```bash
ssh root@YOUR_DROPLET_IP
chmod +x /root/deploy/deploy-openclaw.sh
/root/deploy/deploy-openclaw.sh
```

The installer **asks for credentials interactively** — no manual file editing needed. Have these ready:

- Your Anthropic API key → [console.anthropic.com](https://console.anthropic.com)
- Your OpenAI API key → [platform.openai.com](https://platform.openai.com) (for voice commands — optional)
- Your Discord webhook URL → Discord server → #reports channel → Integrations → Webhooks
- Five Telegram bot tokens → [@BotFather](https://t.me/BotFather) on Telegram

### 3. Verify

```bash
systemctl is-active openclaw            # should say: active
su - clawuser -c "openclaw status"      # gateway + 5 agents
su - clawuser -c "openclaw agents list --bindings"
```

Full student walkthrough: **[../Student_Setup_Guide.md](../Student_Setup_Guide.md)**

---

## What the Installer Does

The `deploy-openclaw.sh` script runs 10 phases automatically:

| Phase | What happens |
|-------|-------------|
| 1. Server Prep | Creates 2 GB swap, installs packages, configures UFW firewall |
| 2. Node.js | Installs Node.js 24 via NodeSource |
| 3. OpenClaw | Installs OpenClaw globally via npm, creates `clawuser` |
| 4. Workspaces | Deploys all 5 agent workspaces (SOUL.md, skills, memory) |
| 5. Config | Writes `openclaw.json` with your API keys, bot tokens, exec permissions |
| 6. Permissions | Sets correct file ownership and modes |
| 7. tmpfiles.d | Creates persistent temp dirs that survive reboots |
| 8. Systemd | Installs and starts `openclaw.service` |
| 9. Dashboard | Installs Shiny for Python dashboard on port 8050 |
| 10. Cron | Adds 6 scheduled jobs (research, memo, coding, monitoring, R&D, cleanup) |

---

## Agent Roster

| Agent | Telegram Bot | Model | Role |
|-------|-------------|-------|------|
| **Henry** | @YourHenryBot | Claude Opus 4.7 | Chief of Staff — orchestrates the team |
| **Coder** | @YourCoderBot | Claude Sonnet 4.6 | Software Engineer — code, data analysis |
| **Scout** | @YourScoutBot | Claude Haiku 4.5 | Research Analyst — web research, trends |
| **Writer** | @YourWriterBot | Claude Sonnet 4.6 | Content Creator — memos, reports |
| **Watcher** | @YourWatcherBot | Claude Haiku 4.5 | System Monitor — health checks, alerts |

All 5 agents post responses to the Discord `#reports` channel automatically.

---

## Cron Schedule

| Time | Agent | Task |
|------|-------|------|
| Every 30 min | Watcher | System health check (Discord alert only if issue) |
| 8:00 AM daily | Scout | Web research scan → Discord #reports |
| 9:00 AM daily | Writer | Morning intelligence memo → Discord #reports |
| 11:00 PM daily | Henry | Nightly R&D strategy session → Discord #reports |
| 2:00 AM daily | Coder | Process queued dev tasks → Discord #reports |
| 4:00 AM Sundays | Watcher | Weekly session cleanup → Discord #reports |

---

## Package Contents

```
deploy/
├── deploy-openclaw.sh           ← Main interactive installer (run this)
├── openclaw.service             ← Systemd unit for OpenClaw gateway
├── clawinc-dashboard.service    ← Systemd unit for Shiny dashboard
├── openclaw-tmpfiles.conf       ← tmpfiles.d config (persistent /tmp dirs)
└── configs/
    ├── openclaw.json            ← Gateway config template
    ├── workspace-henry/
    │   ├── SOUL.md              ← Henry's personality / system prompt
    │   ├── AGENTS.md            ← Henry's knowledge of other agents
    │   ├── MEMORY.md            ← Bootstrap memory
    │   └── skills/
    │       ├── delegate-task/SKILL.md
    │       ├── daily-standup/SKILL.md
    │       ├── discord-report/SKILL.md
    │       └── rnd-meeting/SKILL.md
    ├── workspace-coder/
    │   └── skills/ (vibe-code, debug-app, deploy-app, discord-report)
    ├── workspace-scout/
    │   └── skills/ (web-research, trend-monitor, news-digest, discord-report)
    ├── workspace-writer/
    │   └── skills/ (write-memo, write-report, content-plan, discord-report)
    └── workspace-watcher/
        ├── HEARTBEAT.md
        └── skills/ (health-check, log-analyzer, session-cleanup, discord-report)
```

---

## Server File Layout (after install)

```
/home/clawuser/.openclaw/
├── openclaw.json                ← Master config (contains your API keys)
├── exec-approvals.json          ← Exec permission settings
├── logs/openclaw.log            ← Gateway activity log
├── workspace-henry/
├── workspace-coder/
├── workspace-scout/
├── workspace-writer/
└── workspace-watcher/

/opt/clawinc-dashboard/          ← Shiny monitoring dashboard
/etc/systemd/system/openclaw.service
/etc/systemd/system/clawinc-dashboard.service
/etc/tmpfiles.d/openclaw.conf
```

---

## Useful Commands

```bash
# Service management
systemctl status openclaw
systemctl restart openclaw
journalctl -u openclaw -f

systemctl status clawinc-dashboard
journalctl -u clawinc-dashboard -n 30 --no-pager

# Agent management (run as clawuser)
su - clawuser -c "openclaw status"
su - clawuser -c "openclaw agents list --bindings"
su - clawuser -c "openclaw cron list"
su - clawuser -c "openclaw doctor"
su - clawuser -c "openclaw config validate"

# Memory search
su - clawuser -c "openclaw memory search 'query' --agent scout"

# Test Discord webhook
curl -X POST "YOUR_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content": "test from ClawInc"}'
```

---

## Dashboard

ClawInc includes a read-only Shiny for Python dashboard on port 8050. No SSH tunnel needed.

```
http://YOUR_DROPLET_IP:8050
```

Shows: gateway status, all 5 agent cards, CPU/RAM/disk gauges, Telegram bot bindings, cron schedule, live activity log.

---

## Security

- OpenClaw gateway: listens on `127.0.0.1:18789` only (not publicly accessible)
- Shiny dashboard: port 8050 is public and read-only (no write access)
- UFW firewall: only SSH (22) and dashboard (8050) open
- All config files: `chmod 600` (owner only)
- Gateway runs as `clawuser` (not root)
- systemd: `NoNewPrivileges=true`, `ProtectSystem=strict`, `MemoryMax=512M`

---

*MKT/IDS 518 · University of Illinois at Chicago · J. Christopher Westland*

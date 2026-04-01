# ClawInc — OpenClaw Multi-Agent Deployment

## Quick Start

### 1. Edit Configuration
Open `deploy-openclaw.sh` and fill in the CONFIGURATION section at the top:

```bash
ANTHROPIC_API_KEY="sk-ant-..."          # Required
OPENAI_API_KEY="sk-proj-..."            # Optional
TELEGRAM_TOKEN_HENRY="123456:ABC..."    # From @BotFather
TELEGRAM_TOKEN_CODER="123456:ABC..."
TELEGRAM_TOKEN_SCOUT="123456:ABC..."
TELEGRAM_TOKEN_WRITER="123456:ABC..."
TELEGRAM_TOKEN_WATCHER="123456:ABC..."
```

### 2. Create Telegram Bots
Message [@BotFather](https://t.me/BotFather) on Telegram and create 5 bots:
1. `HenryClawBot` — Chief of Staff
2. `CoderClawBot` — Software Engineer
3. `ScoutClawBot` — Research Analyst
4. `WriterClawBot` — Content Creator
5. `WatcherClawBot` — System Monitor

Copy each bot token into the script.

### 3. Upload to Server
```bash
scp -r deploy/ root@137.184.15.207:/root/deploy/
```

### 4. SSH in and Run
```bash
ssh root@137.184.15.207
chmod +x /root/deploy/deploy-openclaw.sh
/root/deploy/deploy-openclaw.sh
```

The script will:
- Create 2GB swap (critical for 1GB RAM server)
- Install Node.js 24 and OpenClaw
- Configure all 5 agents with their workspaces
- Set up cron jobs (morning research, daily memo, overnight coding, health checks, R&D)
- Harden security (firewall, file permissions, gateway on localhost only)
- Start the OpenClaw gateway as a systemd service
- Optionally install Mission Control dashboard

### 5. Verify
```bash
openclaw status
openclaw agents list --bindings
openclaw doctor
openclaw cron list
free -h          # Should show 2GB swap
ufw status       # Should show only SSH
```

### 6. Access Mission Control
```bash
ssh -L 3000:localhost:3000 -L 4200:localhost:4200 root@137.184.15.207
```
Then open http://localhost:3000 in your browser.

---

## Agent Roster

| Agent | Role | Model | Schedule |
|-------|------|-------|----------|
| **Henry** | Chief of Staff / Orchestrator | Claude Opus 4.6 | 11PM R&D session |
| **Coder** | Software Engineer | Claude Sonnet 4.5 | 2AM overnight dev |
| **Scout** | Research Analyst | Claude Haiku 4.5 | 8AM daily research |
| **Writer** | Content Creator | Claude Sonnet 4.5 | 9AM daily memo |
| **Watcher** | System Monitor | Claude Haiku 4.5 | Every 30min health check |

## Cron Schedule

| Time | Agent | Task |
|------|-------|------|
| Every 30 min | Watcher | System health check |
| 8:00 AM | Scout | Web research scan |
| 9:00 AM | Writer | Compile morning memo |
| 11:00 PM | Henry | R&D analysis session |
| 2:00 AM | Coder | Overnight development |
| 4:00 AM Sun | Watcher | Weekly session cleanup |

## File Structure
```
~/.openclaw/
├── openclaw.json           ← Master configuration
├── logs/
├── workspace-henry/        ← Orchestrator
│   ├── SOUL.md, AGENTS.md, MEMORY.md
│   ├── memory/
│   └── skills/ (delegate-task, daily-standup, rnd-meeting)
├── workspace-coder/        ← Software Engineer
│   ├── SOUL.md, AGENTS.md, MEMORY.md
│   ├── memory/
│   └── skills/ (vibe-code, debug-app, deploy-app)
├── workspace-scout/        ← Research Analyst
│   ├── SOUL.md, AGENTS.md, MEMORY.md
│   ├── memory/
│   └── skills/ (web-research, trend-monitor, news-digest)
├── workspace-writer/       ← Content Creator
│   ├── SOUL.md, AGENTS.md, MEMORY.md
│   ├── memory/
│   └── skills/ (write-memo, write-report, content-plan)
├── workspace-watcher/      ← System Monitor
│   ├── SOUL.md, AGENTS.md, MEMORY.md, HEARTBEAT.md
│   ├── memory/
│   └── skills/ (health-check, log-analyzer, session-cleanup)
└── agents/ (henry, coder, scout, writer, watcher)
```

## Useful Commands
```bash
# Service management
systemctl status openclaw
systemctl restart openclaw
journalctl -u openclaw -f

# Agent management
openclaw status
openclaw agents list --bindings
openclaw doctor
openclaw cron list

# Memory search
openclaw memory search "query" --agent henry

# Manual agent interaction
openclaw chat henry "run the daily standup"
```

## Security Notes
- Gateway listens on 127.0.0.1 only (not publicly accessible)
- Access only via SSH tunnel
- All config files are chmod 600, directories chmod 700
- UFW firewall allows only SSH
- Systemd service runs with NoNewPrivileges=true, ProtectSystem=strict
- Gateway auth token is 64 characters (saved in /root/.openclaw-gateway-token)

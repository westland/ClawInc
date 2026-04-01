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
Message [@BotFather](https://t.me/BotFather) on Telegram and create 4 bots (Watcher runs headlessly with no Telegram bot):
1. `HenryClawBot` — Chief of Staff
2. `CoderClawBot` — Software Engineer
3. `ScoutClawBot` — Research Analyst
4. `WriterClawBot` — Content Creator

Copy each bot token into the script.

### 3. Upload to Server
```bash
scp -r deploy/ root@YOUR_DROPLET_IP:/root/deploy/
scp -r dashboard/ root@YOUR_DROPLET_IP:/opt/clawinc-dashboard/
```

### 4. SSH in and Run
```bash
ssh root@YOUR_DROPLET_IP
chmod +x /root/deploy/deploy-openclaw.sh
/root/deploy/deploy-openclaw.sh
```

The script will:
- Create 2GB swap (critical for 1GB RAM server)
- Install Node.js 24 and OpenClaw
- Configure all 5 agents with their workspaces
- Set up 6 cron jobs (morning research, daily memo, overnight coding, health checks, R&D, cleanup)
- Harden security (firewall, file permissions, gateway on localhost only)
- Start the OpenClaw gateway as a systemd service

### 5. Install Shiny Dashboard
```bash
apt-get install -y python3.12-venv
python3 -m venv /opt/clawinc-dashboard/venv
/opt/clawinc-dashboard/venv/bin/pip install shiny psutil
cp /root/deploy/clawinc-dashboard.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now clawinc-dashboard
ufw allow 8050/tcp
```

### 6. Verify
```bash
systemctl is-active openclaw           # should say: active
systemctl is-active clawinc-dashboard  # should say: active
sudo -u clawuser openclaw status
sudo -u clawuser openclaw cron list
free -h                                # should show 2GB swap
ufw status                             # should show SSH + 8050
```

---

## Accessing Your Dashboards

### Shiny Monitoring Dashboard (recommended for students)
Open directly in any browser — no SSH required, no token needed:
```
http://YOUR_DROPLET_IP:8050
```
Shows: all 5 agent cards, CPU/RAM/disk gauges, Telegram bot bindings, cron job schedule, live activity log. Auto-refreshes every 30 seconds.

### OpenClaw Control UI (admin / instructor use)
Requires an SSH tunnel because the gateway binds to localhost only:

**Step 1** — open the tunnel on your local machine (leave this terminal open):
```bash
ssh -N -L 18789:127.0.0.1:18789 root@YOUR_DROPLET_IP
```

**Step 2** — get the tokenized URL from the server:
```bash
sudo -u clawuser openclaw dashboard
# Outputs: http://localhost:18789/#token=<your-token>
```

**Step 3** — open that URL in your browser. The token authenticates automatically.

The Control UI lets you chat with agents directly, browse session history, view real-time logs, and manage configuration.

---

## Agent Roster

| Agent | Role | Model | Telegram | Schedule |
|-------|------|-------|----------|----------|
| **Henry** | Chief of Staff / Orchestrator | Claude Opus 4.6 | @HenryClawBot | 11PM R&D session |
| **Coder** | Software Engineer | Claude Sonnet 4.5 | @CoderClawBot | 2AM overnight dev |
| **Scout** | Research Analyst | Claude Haiku 4.5 | @ScoutClawBot | 8AM daily research |
| **Writer** | Content Creator | Claude Sonnet 4.5 | @WriterClawBot | 9AM daily memo |
| **Watcher** | System Monitor | Claude Haiku 4.5 | — (headless) | Every 30min health check |

## Cron Schedule

| Time | Agent | Task |
|------|-------|------|
| Every 30 min | Watcher | System health check |
| 8:00 AM | Scout | Web research scan |
| 9:00 AM | Writer | Compile morning memo |
| 11:00 PM | Henry | R&D analysis session |
| 2:00 AM | Coder | Overnight development |
| 4:00 AM Sun | Watcher | Weekly session cleanup |

## Server File Structure
```
~/.openclaw/                       (clawuser's home)
├── openclaw.json                  ← Master configuration
├── logs/openclaw.log              ← Gateway activity log
├── workspace-henry/               ← Orchestrator
│   ├── SOUL.md, AGENTS.md, MEMORY.md
│   ├── memory/
│   └── skills/ (delegate-task, daily-standup, rnd-meeting)
├── workspace-coder/               ← Software Engineer
├── workspace-scout/               ← Research Analyst
├── workspace-writer/              ← Content Creator
└── workspace-watcher/             ← System Monitor

/opt/clawinc-dashboard/            (Shiny dashboard)
├── app.py
├── requirements.txt
└── venv/

/etc/systemd/system/
├── openclaw.service               ← Gateway service
└── clawinc-dashboard.service      ← Dashboard service
```

## Useful Commands
```bash
# Service management
systemctl status openclaw
systemctl restart openclaw
journalctl -u openclaw -f

systemctl status clawinc-dashboard
systemctl restart clawinc-dashboard
journalctl -u clawinc-dashboard -f

# Agent management
sudo -u clawuser openclaw status
sudo -u clawuser openclaw cron list
sudo -u clawuser openclaw doctor

# Memory search
sudo -u clawuser openclaw memory search "query" --agent henry

# Manual agent trigger
sudo -u clawuser openclaw chat henry "run the daily standup"

# Get dashboard token
sudo -u clawuser openclaw dashboard
```

## Security Notes
- Gateway listens on 127.0.0.1 only — not publicly accessible
- OpenClaw Control UI (port 18789): SSH tunnel + gateway auth token required
- Shiny Dashboard (port 8050): publicly accessible, read-only (no write access to agents)
- UFW allows: SSH (22) + dashboard (8050). All other ports blocked.
- Config files: chmod 600 (owner read/write only)
- Systemd: `NoNewPrivileges=true`, `ProtectSystem=strict`, `MemoryMax=512M`
- Gateway runs as `clawuser`, not root

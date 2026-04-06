# ClawInc Student Setup Guide: Your Own AI Agent Company

**MKT/IDS 518 — Deploying OpenClaw on DigitalOcean with Telegram and Discord**  
*J. Christopher Westland · University of Illinois at Chicago*

---

> **What you will build:** A company of 5 autonomous AI agents (Henry, Coder, Scout, Writer, Watcher) running 24/7 on a cloud server. You control them by sending messages in Telegram — from your phone or desktop — and they autonomously research, analyze, code, write reports, and monitor your system. Every response is also posted to your Discord server for team visibility.

---

## Table of Contents

1. [Create Your DigitalOcean Droplet](#1-create-your-digitalocean-droplet)
2. [Create Your Telegram Bots](#2-create-your-telegram-bots)
3. [Get Your API Keys](#3-get-your-api-keys)
4. [Set Up Your Discord Server](#4-set-up-your-discord-server)
5. [Deploy OpenClaw on Your Droplet](#5-deploy-openclaw-on-your-droplet)
6. [Verify Everything is Working](#6-verify-everything-is-working)
7. [Access the Monitoring Dashboard](#7-access-the-monitoring-dashboard)
8. [Customizing Your Agents](#8-customizing-your-agents)
9. [Using Your Agents for the Class Project](#9-using-your-agents-for-the-class-project)
10. [Commands Reference](#10-commands-reference)
11. [Troubleshooting](#11-troubleshooting)
12. [Quick-Start Checklist](#appendix-quick-start-checklist)

---

## 1. Create Your DigitalOcean Droplet

### Create a DigitalOcean Account

1. Go to [digitalocean.com](https://www.digitalocean.com) and sign up (use your university email).
2. Add a payment method. A droplet costs **$6/month** (the 1 GB RAM / 1 vCPU plan).
3. You can use a referral link to get $200 in free credits for 60 days.

### Create a Droplet

1. Click **Create → Droplets** in the top menu.
2. Choose these settings:

| Setting | Value |
|---------|-------|
| **Region** | Choose the closest to you (e.g., New York, San Francisco) |
| **Image** | Ubuntu 24.04 (LTS) x64 |
| **Size** | Basic → Regular → **$6/mo** (1 GB RAM, 1 vCPU, 25 GB disk) |
| **Authentication** | Password — set a strong root password and save it |
| **Hostname** | `ClawInc` (or your company name) |

3. Click **Create Droplet**. Wait 60 seconds for it to boot.
4. Note your droplet's **IP address** (shown in the DigitalOcean dashboard). You will use this everywhere.

### Connect to Your Droplet

- **Windows:** Use Windows Terminal: `ssh root@YOUR_IP`
- **Mac/Linux:** Open Terminal: `ssh root@YOUR_IP`
- **Browser:** DigitalOcean dashboard → your droplet → **Access → Launch Droplet Console**

```bash
ssh root@YOUR_DROPLET_IP
# Enter your root password when prompted
```

You should see a prompt like `root@ClawInc:~#`.

---

## 2. Create Your Telegram Bots

You need **5 Telegram bots** (one per agent). Free and takes about 5 minutes.

### Install Telegram

- **Phone:** Download from the App Store or Google Play.
- **Desktop:** Download from [telegram.org/apps](https://telegram.org/apps).

### Create Bots with BotFather

1. In Telegram, search for **@BotFather** (the official bot creation service — blue checkmark).
2. Start a chat and send `/newbot`.
3. Create **5 bots** one at a time:

| Bot Name | Username (must end in `bot`) | Agent Role |
|----------|------------------------------|------------|
| Henry ClawBot | `henryclawbot` | Chief of Staff — main command interface, orchestrates the team |
| Coder ClawBot | `coderclawbot` | Software Engineer — writes and runs code, data analysis |
| Scout ClawBot | `scoutclawbot` | Research Analyst — web research and trend monitoring |
| Writer ClawBot | `writerclawbot` | Content Creator — memos, reports, executive summaries |
| Watcher ClawBot | `watcherclawbot` | System Monitor — health checks, alerts, maintenance |

4. After each `/newbot`, BotFather gives you a **bot token** like:
   ```
   8732631641:AAHu1OuUh8uRXqpZqH_6G77DMOwIAXVaRKU
   ```
5. **Save all 5 tokens** in a text file. You will need them in Step 5.

> To create the next bot, just send `/newbot` to BotFather again.

---

## 3. Get Your API Keys

### Anthropic API Key (Required — powers all 5 agents)

1. Go to [console.anthropic.com](https://console.anthropic.com) and sign up.
2. Go to **API Keys → Create Key**.
3. Name it `ClawInc` and copy the key (starts with `sk-ant-api03-...`).
4. **Save it.** You cannot view it again after closing the page.

> **Cost estimate:** Typical class project usage is $5–$20/month depending on how active your agents are.

### OpenAI API Key (For voice commands)

Voice messages sent to your bots are automatically transcribed using OpenAI's audio API. Without this key, voice commands will not work — your agents will only respond to typed text.

1. Go to [platform.openai.com](https://platform.openai.com) and sign up.
2. Go to **API Keys → Create new secret key**.
3. Name it `ClawInc` and copy the key (starts with `sk-proj-...`).
4. **Save it.**

> **Cost:** OpenAI voice transcription is extremely cheap — typically a few cents per month for class project usage.

> **Optional:** You can skip this step and add the key later by editing `/home/clawuser/.openclaw/openclaw.json` on the server and restarting the gateway.

---

## 4. Set Up Your Discord Server

Every agent posts its responses and reports to a Discord channel. This gives you a shared log visible to your whole team.

### Create a Discord Server

1. Go to [discord.com](https://discord.com) and sign up if you do not have an account.
2. In the left sidebar, click the **+** icon → **Create My Own** → **For me and my friends**.
3. Name it **ClawInc** (or your company name). Click **Create**.

### Create the Reports Channel

1. In your new server, click the **+** next to **TEXT CHANNELS**.
2. Name the channel `reports`. Leave it public.
3. Click **Create Channel**.

### Create a Webhook

1. Click the gear icon next to the `#reports` channel → **Edit Channel**.
2. Go to **Integrations → Webhooks → New Webhook**.
3. Name it `ClawInc Reports`.
4. Click **Copy Webhook URL**. It looks like:
   ```
   https://discord.com/api/webhooks/123456789/ABCDEFGHIJ...
   ```
5. **Save this URL.** You will put it in the deploy script in Step 5.

---

## 5. Deploy OpenClaw on Your Droplet

### Upload the Deploy Package

From your **local computer**, copy the deploy files to your server.

**Mac/Linux** — open Terminal and run:
```bash
scp -r deploy/ root@YOUR_DROPLET_IP:/root/deploy/
```

**Windows** — use [WinSCP](https://winscp.net) (free):
1. Open WinSCP → New Session
2. Protocol: SCP, Hostname: YOUR_DROPLET_IP, Username: `root`, Password: your root password
3. Click Login, then drag the entire `deploy/` folder from your computer to `/root/` on the server.

### Run the Deploy Script

SSH into your server, then run:

```bash
chmod +x /root/deploy/deploy-openclaw.sh
/root/deploy/deploy-openclaw.sh
```

The installer is **interactive** — it will ask you for each credential one at a time. Have the following ready:

| Prompt | Where to find it |
|--------|-----------------|
| Server IP address | DigitalOcean dashboard |
| Anthropic API key | console.anthropic.com |
| OpenAI API key | platform.openai.com (for voice commands — press Enter to skip) |
| Discord webhook URL | Discord → #reports → Integrations → Webhooks |
| Telegram token for Henry | Saved from @BotFather Step 2 |
| Telegram token for Coder | Saved from @BotFather Step 2 |
| Telegram token for Scout | Saved from @BotFather Step 2 |
| Telegram token for Writer | Saved from @BotFather Step 2 |
| Telegram token for Watcher | Saved from @BotFather Step 2 |

Just type or paste each value when prompted and press Enter.

This takes **10–15 minutes** and will:

- Create 2 GB of swap space (essential for a 1 GB RAM server)
- Install Node.js 24 and OpenClaw
- Set up the 5 agent workspaces with their personalities, skills, and memory
- Configure all 5 Telegram bots and the Discord webhook
- Deploy and start the monitoring dashboard on port 8050
- Start the OpenClaw gateway service

### Add Cron Jobs

Run these commands to set up the automated daily schedule:

```bash
su - clawuser << 'CRONEOF'

openclaw cron add \
  --name "morning-research" --agent "scout" \
  --cron "0 8 * * *" --session isolated \
  --message "Run your morning research routine. Search the web for the latest trending topics in AI, marketing analytics, and technology. Focus on developments from the last 24 hours. Write a structured briefing with key findings, notable trends, and actionable insights. Save the briefing to your memory. Then post a signed summary to the Discord #reports channel using your discord-report skill."

openclaw cron add \
  --name "daily-memo" --agent "writer" \
  --cron "0 9 * * *" --session isolated \
  --message "Compile the morning memo. Search Scout memory for today's research briefing. Synthesize into a polished executive memo with sections: Top Stories, Trend Analysis, Action Items, Market Watch. Save to your memory. Post the memo to Discord #reports using your discord-report skill."

openclaw cron add \
  --name "overnight-worker" --agent "coder" \
  --cron "0 2 * * *" --session isolated \
  --message "Check your task queue and Henry's recent delegations. Work on the highest-priority pending development task. If no tasks queued, review code for improvements and document technical debt found. Post a summary to Discord #reports using your discord-report skill."

openclaw cron add \
  --name "health-check" --agent "watcher" \
  --cron "*/30 * * * *" --session isolated \
  --message "Check system resources (CPU, RAM, disk, swap), verify agents are responsive, review error logs. Only alert Henry and post to Discord if something is wrong."

openclaw cron add \
  --name "nightly-rnd" --agent "henry" \
  --cron "0 23 * * *" --session isolated \
  --message "Initiate the nightly R&D session. Review today's memo from Writer, research from Scout, and any code from Coder. Identify opportunities and strategic improvements. Delegate follow-up tasks to team members as needed. Post a summary to Discord #reports using your discord-report skill."

openclaw cron add \
  --name "session-cleanup" --agent "watcher" \
  --cron "0 4 * * 0" --session isolated \
  --message "Perform weekly session cleanup. Archive sessions older than 7 days. Clean up temporary files. Report storage savings to Henry and post to Discord #reports using your discord-report skill."

openclaw cron list
CRONEOF
```

You should see a table of 6 scheduled jobs.

---

## 6. Verify Everything is Working

### Check System Status

```bash
su - clawuser -c "openclaw status"
```

Look for:
- **Gateway:** `reachable`
- **Agents:** `5`
- **Channels:** all 5 Telegram bots listed

```bash
su - clawuser -c "openclaw agents list --bindings"
```

### Test Your Bots in Telegram

1. Open Telegram and search for your Henry bot (e.g., `@henryclawbot`).
2. Press **START** or send `/start`.
3. Send: `Hello! Who are you and what can you do?`
4. Henry (Claude Opus) should respond within a few seconds. That response will also appear in your Discord `#reports` channel.

Repeat for Coder, Scout, Writer, and Watcher.

> **If a bot does not respond:** Check logs with `journalctl -u openclaw -f`

### Test Discord Integration

After messaging any bot, check your Discord `#reports` channel. You should see a color-coded embed from that agent:

| Agent | Discord Color |
|-------|--------------|
| Henry | Gold |
| Coder | Blue |
| Scout | Green |
| Writer | Purple |
| Watcher | Orange |

---

## 7. Access the Monitoring Dashboard

ClawInc includes a **Shiny for Python** dashboard on port 8050. No SSH tunnel needed.

```
http://YOUR_DROPLET_IP:8050
```

| Section | What it shows |
|---------|---------------|
| **System** | Gateway status, CPU %, RAM, disk usage |
| **Agents** | Card per agent — model, workspace state, thinking level |
| **Telegram Bots** | All 5 bots with their agent routing |
| **Cron Jobs** | Current scheduled job list |
| **Activity Log** | Live tail of the OpenClaw log file |

The dashboard is **read-only**. Use Telegram to send commands.

```bash
# Restart dashboard if needed
systemctl restart clawinc-dashboard

# View dashboard logs
journalctl -u clawinc-dashboard -n 30 --no-pager
```

---

## 8. Customizing Your Agents

### Editing an Agent's Personality (SOUL.md)

Each agent's personality is defined in a `SOUL.md` file:

```bash
nano /home/clawuser/.openclaw/workspace-henry/SOUL.md
```

After saving, restart the gateway:

```bash
systemctl restart openclaw
```

### Adding Skills

Skills are Markdown task templates in each agent's `skills/` folder:

```bash
ls /home/clawuser/.openclaw/workspace-scout/skills/
```

### Changing Agent Models

Edit `openclaw.json`:

```bash
nano /home/clawuser/.openclaw/openclaw.json
```

| Model | Speed | Intelligence | Cost |
|-------|-------|-------------|------|
| `anthropic/claude-opus-4-6` | Slow | Highest | High |
| `anthropic/claude-sonnet-4-5-20250929` | Medium | High | Medium |
| `anthropic/claude-haiku-4-5-20251001` | Fast | Good | Low |

After editing:

```bash
su - clawuser -c "openclaw config validate"
systemctl restart openclaw
```

---

## 9. Using Your Agents for the Class Project

### Talking to Your Agents

Send messages directly to any Telegram bot. Every response also posts to Discord `#reports`.

**Henry — Chief of Staff (Claude Opus 4.6):**
```
Research the top 3 trends in social media marketing in Q1 2026,
then have Scout do a deep web analysis and Writer produce
a 2-page executive brief. Post everything to Discord when done.
```

**Coder — Software Engineer (Claude Sonnet 4.5):**
```
I'm uploading a CSV of customer purchase data. Run a regression
analysis to find the top predictors of purchase frequency.
Generate a Python script and show me the output.
```

**Scout — Research Analyst (Claude Haiku 4.5):**
```
Search the web for recent academic papers on customer segmentation
using AI. Summarize the top 5 findings with citations.
```

**Writer — Content Creator (Claude Sonnet 4.5):**
```
Write a 500-word executive summary of our Q1 marketing strategy,
using a formal business style. Include an executive abstract,
3 key findings, and 2 recommendations.
```

**Watcher — System Monitor (Claude Haiku 4.5):**
```
Run a full health check and give me a status report on all agents
and server resources.
```

### Using Henry for Multi-Agent Tasks

Henry is your Chief of Staff and can coordinate the entire team:

> *"Henry, have Scout research the latest trends in influencer marketing and have Writer turn the findings into a one-page brief. Post both to Discord when done."*

Henry decomposes the request, delegates to Scout and Writer in sequence, and synthesizes the result.

### Voice Commands

Voice notes in Telegram require **Telegram Premium**. Without Premium, type your commands as text — agents respond identically.

> Voice *calls* do not reach the agents. Only voice *notes* (hold the mic button) work, and only with Telegram Premium.

### Checking Agent Memory

```bash
su - clawuser -c "openclaw memory search 'marketing trends' --agent scout"
```

---

## 10. Commands Reference

### Server Management

```bash
systemctl is-active openclaw          # Check gateway is running
systemctl restart openclaw            # Restart (applies config changes)
journalctl -u openclaw -f             # Live logs
free -h                               # RAM and swap
df -h /                               # Disk space
```

### OpenClaw Commands (run as clawuser)

```bash
su - clawuser                         # Switch to clawuser

openclaw status                       # Overall status
openclaw agents list --bindings       # All 5 agents and Telegram connections
openclaw cron list                    # Scheduled jobs
openclaw cron run morning-research    # Run a cron job now (for testing)
openclaw memory search "query" --agent scout
openclaw channels status --probe      # Verify Telegram bot connections
openclaw doctor                       # Run diagnostics
openclaw config validate              # Validate config file
```

### Edit Config

```bash
nano /home/clawuser/.openclaw/openclaw.json
su - clawuser -c "openclaw config validate"
systemctl restart openclaw
```

---

## 11. Troubleshooting

### Bot Not Responding

1. `systemctl is-active openclaw`
2. `journalctl -u openclaw -n 50 --no-pager`
3. Verify bot token in `openclaw.json` matches BotFather
4. `su - clawuser -c "openclaw channels status --probe"`
5. Restart: `systemctl restart openclaw`

### Discord Posts Not Appearing

1. Check `DISCORD_WEBHOOK_URL` is set: `grep DISCORD /home/clawuser/.openclaw/openclaw.json`
2. Test the webhook manually:
   ```bash
   curl -X POST "YOUR_WEBHOOK_URL" -H "Content-Type: application/json" \
     -d '{"content": "test from ClawInc"}'
   ```
3. Make sure the `#reports` channel exists and the webhook points to it.

### Config Invalid

```bash
su - clawuser -c "openclaw config validate"
```

Check: JSON syntax, no trailing commas, all brackets matched, bot tokens in `NUMBER:LETTERS` format.

### Gateway Not Starting

```bash
journalctl -u openclaw -n 30 --no-pager
ss -tlnp | grep 18789                 # Check if port is in use
su - clawuser -c "openclaw gateway run"   # Run manually to see error
```

### Ran Out of Memory

```bash
free -h    # Swap should show 2GB

# Recreate swap if missing:
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

### Lost Your Root Password

DigitalOcean Dashboard → Your Droplet → **Access → Reset Root Password**

---

## Appendix: Quick-Start Checklist

- [ ] Created DigitalOcean account and droplet (Ubuntu 24.04, $6/mo)
- [ ] Noted my droplet IP address: ________________
- [ ] Installed Telegram on phone and/or desktop
- [ ] Created **5 bots** via @BotFather and saved all 5 tokens
- [ ] Got Anthropic API key from console.anthropic.com
- [ ] Got OpenAI API key from platform.openai.com (for voice commands)
- [ ] Created Discord server with `#reports` channel
- [ ] Created Discord webhook and saved the URL
- [ ] Uploaded `deploy/` folder to `/root/deploy/` on server
- [ ] Edited deploy script with API key, Discord webhook, and all 5 bot tokens
- [ ] Ran deploy script successfully
- [ ] Config valid: `openclaw config validate` shows **Config valid**
- [ ] Service active: `systemctl is-active openclaw` shows **active**
- [ ] All 5 bots respond in Telegram
- [ ] Agent responses appear in Discord `#reports`
- [ ] Dashboard accessible at `http://YOUR_IP:8050`
- [ ] All 6 cron jobs added: `openclaw cron list`

---

## Appendix: Agent Roster

| Agent | Telegram Bot | Model | Role | Discord Color |
|-------|-------------|-------|------|---------------|
| **Henry** | @YourHenryBot | Claude Opus 4.6 | Chief of Staff — orchestrates the team | Gold |
| **Coder** | @YourCoderBot | Claude Sonnet 4.5 | Software Engineer — code, data analysis | Blue |
| **Scout** | @YourScoutBot | Claude Haiku 4.5 | Research Analyst — web research, trends | Green |
| **Writer** | @YourWriterBot | Claude Sonnet 4.5 | Content Creator — reports, memos | Purple |
| **Watcher** | @YourWatcherBot | Claude Haiku 4.5 | System Monitor — health checks, alerts | Orange |

---

## Appendix: Cron Schedule

| Time | Agent | Task |
|------|-------|------|
| Every 30 min | Watcher | System health check (posts to Discord only if alert) |
| 8:00 AM daily | Scout | Web research scan → Discord #reports |
| 9:00 AM daily | Writer | Morning intelligence memo → Discord #reports |
| 11:00 PM daily | Henry | Nightly R&D strategy session → Discord #reports |
| 2:00 AM daily | Coder | Process queued development tasks → Discord #reports |
| 4:00 AM Sundays | Watcher | Weekly session cleanup → Discord #reports |

---

*For questions, contact your instructor. For live system status, open `http://YOUR_DROPLET_IP:8050` in your browser.*

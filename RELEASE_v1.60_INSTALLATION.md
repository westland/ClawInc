# DermaArtIA v1.60 Release & Installation Guide

This document outlines the upgrade and installation steps to deploy **DermaArtIA v1.60** on your cloud server.

DermaArtIA v1.60 completely removes all Discord dependencies and terminology from the agents' instructions and skills, ensuring all retrospective and system health briefings are routed directly to the bespoke web portal's **Reports & Memos** screen.

## Key Updates in v1.60

1. **Rebranded Agent Beliefs & Instructions**:
   - Replaced all Discord terminology with "Reports & Memos screen on the Portal" in agent instructions (`portal-report/SKILL.md` for Coder, Henry, Scout, Watcher, and Writer).
   - Rebranded Watcher's health-check skill (`health-check/SKILL.md`) to alert the portal instead of Discord.
   - Rebranded Henry's delegation skill (`delegate-task.md`) examples to post to the portal instead of a Discord channel.
2. **Simplified reporting payloads**:
   - Simplified the Python code block in agent skills to fetch `PORTAL_REPORTS_URL` and send simple direct JSON payloads (`{"content": body}`) rather than complex Discord embeds.
3. **Robust Backend API Validation**:
   - Updated the FastAPI backend schema (`portal/main.py`) to support legacy Discord webhook structures (extracting the description from embeds) in addition to direct content. This guarantees zero validation failures (`422 Unprocessable Entity`) for legacy sessions or old code blocks.
4. **Flexible environment setup**:
   - Configured `deploy-openclaw.sh` and `openclaw.json` to prompt for and set `PORTAL_REPORTS_URL` alongside `DISCORD_WEBHOOK_URL` to support seamless backward compatibility.

---

## 1. Pull the Latest Repository Code

Connect to your server via SSH and navigate to your git clone directory (default: `/root/DermaArtIA`). Pull the v1.60 updates:
```bash
cd /root/DermaArtIA
git pull origin main
```

---

## 2. Run the Deployment Script

Deploy the new configs, templates, and agent skills (including the updated Coder workspace template):
```bash
# Make the deployment scripts executable
chmod +x /root/DermaArtIA/deploy/deploy-openclaw.sh

# Run the deployment using your existing API credentials
export NON_INTERACTIVE=1
export SERVER_IP="YOUR_DROPLET_IP"
export GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
export PORTAL_REPORTS_URL="http://127.0.0.1:8000/api/reports/submit"
export DISCORD_WEBHOOK_URL="http://127.0.0.1:8000/api/reports/submit"
/root/DermaArtIA/deploy/deploy-openclaw.sh
```

---

## 3. Restart and Verify Services

1. Restart the OpenClaw agent gateway and the portal API:
   ```bash
   systemctl restart openclaw
   systemctl restart dermaart-portal
   ```
2. Verify that all 5 scheduled jobs are enqueued correctly and have the correct delivery status:
   ```bash
   su - clawuser -c 'openclaw cron list'
   ```
3. Test a manual execution of Scout's morning scan:
   ```bash
   su - clawuser -c 'openclaw cron run morning-research-daily'
   ```
4. Verify that the output is successfully saved to the portal database and visible on the Reports & Memos screen on your website at: `http://YOUR_SERVER_IP` (Login: `sumar` / `#1DermaArt`).

---
*Copyright © 2026 J. Christopher Westland, all rights reserved · v1.60*

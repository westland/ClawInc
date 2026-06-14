# DermaArtIA v1.87 Patch Release & Installation Guide

This document outlines the upgrade and installation steps to deploy **DermaArtIA v1.87** on your cloud server.

DermaArtIA v1.87 is a maintenance patch that addresses persistent false-alarm critical health check alerts reported by the system watcher agent.

## Key Updates in v1.87

1. **Resolved Watcher Gateway Status False Alarm**:
   - Corrected the OpenClaw service status check from querying a user-level service (`systemctl --user is-active openclaw-gateway.service`) to checking the system-level service (`systemctl is-active openclaw.service`).

2. **Resolved Nginx 404/Inactive False Alarms**:
   - Replaced `urllib.request` library checks with robust `curl` status code checks.
   - Expanded the accepted HTTP status codes list to include `301` (redirect to HTTPS) and `404` (Nginx default response on port 80 for `127.0.0.1`).
   - Ensured that Nginx/Portal is not flagged as "inactive" in the log when returning unexpected status codes (they are flagged as active but with a warning).

---

## 1. Pull the Latest Repository Code

Connect to your server via SSH and navigate to your git clone directory (default: `/root/DermaArtIA`). Pull the v1.87 updates:
```bash
cd /root/DermaArtIA
git pull origin main
```

---

## 2. Run the Deployment Script

Deploy the new configs, templates, and agent skills:
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
2. Verify that the scheduled jobs run successfully without errors:
   ```bash
   su - clawuser -c 'openclaw cron run health-check-main'
   ```
3. Check the latest log reports in Watcher's workspace or reports database.

---
*Copyright © 2026 J. Christopher Westland, all rights reserved · v1.87*

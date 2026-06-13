#!/usr/bin/env bash
# =============================================================================
# deploy-openclaw.sh — ClawInc v2.15 Multi-Agent Company Installer
# =============================================================================
# Installs a complete 5-agent AI company on Ubuntu 24.04 (DigitalOcean).
#
# Run this script as root on your fresh DigitalOcean droplet:
#
#   scp -r deploy/ root@YOUR_IP:/root/deploy/
#   ssh root@YOUR_IP
#   chmod +x /root/deploy/deploy-openclaw.sh
#   /root/deploy/deploy-openclaw.sh
#
# The script will ask you for all required credentials interactively.
# Have the following ready before you start:
#   - Your Anthropic API key  (from console.anthropic.com)
#   - Your Discord webhook URL (from your Discord server settings)
#   - Your 5 Telegram bot tokens (from @BotFather on Telegram)
# =============================================================================

set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAW_USER="clawuser"
OPENCLAW_DIR="/home/${CLAW_USER}/.openclaw"
LOG_FILE="/var/log/openclaw-deploy.log"
VERSION="2.15"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log()    { echo -e "${GREEN}[✓]${NC} $*" | tee -a "$LOG_FILE"; }
warn()   { echo -e "${YELLOW}[!]${NC} $*" | tee -a "$LOG_FILE"; }
error()  { echo -e "${RED}[✗]${NC} $*" | tee -a "$LOG_FILE"; }
header() { echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
           echo -e "${BLUE}  ${BOLD}$*${NC}" | tee -a "$LOG_FILE"
           echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n" | tee -a "$LOG_FILE"; }
prompt() { echo -e "${CYAN}▶ $*${NC}"; }

mkdir -p "$(dirname "$LOG_FILE")"
echo "=== ClawInc v${VERSION} Deploy Log — $(date) ===" > "$LOG_FILE"

# =============================================================================
# STEP 0: Welcome and credential collection
# =============================================================================

clear
echo -e "${BOLD}${BLUE}"
cat << 'BANNER'
  ██████╗██╗      █████╗ ██╗    ██╗██╗███╗   ██╗ ██████╗
 ██╔════╝██║     ██╔══██╗██║    ██║██║████╗  ██║██╔════╝
 ██║     ██║     ███████║██║ █╗ ██║██║██╔██╗ ██║██║
 ██║     ██║     ██╔══██║██║███╗██║██║██║╚██╗██║██║
 ╚██████╗███████╗██║  ██║╚███╔███╔╝██║██║ ╚████║╚██████╗
  ╚═════╝╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝
BANNER
echo -e "${NC}"
echo -e "${BOLD}  ClawInc Multi-Agent AI Company — v${VERSION} Installer${NC}"
echo -e "  OOM fixes · Symlink repair · Cron jobs via jobs.json · Handshake timeout fix · Bonjour/mDNS disabled"
echo -e "  Voice commands supported via OpenAI audio transcription"
echo -e "  Deploys 5 autonomous AI agents (Henry, Coder, Scout, Writer, Watcher)"
echo -e "  Controlled via Telegram · Reports posted to Web Portal\n"
echo -e "${YELLOW}  Before continuing, make sure you have:${NC}"
echo -e "  1. Your Anthropic API key   → console.anthropic.com (required)"
echo -e "  2. Your OpenAI API key      → platform.openai.com (for voice commands)"
echo -e "  3. Your Portal Reports API URL (default: http://127.0.0.1:8000/api/reports/submit)"
echo -e "  4. Five Telegram bot tokens → @BotFather on Telegram\n"
if [[ -z "${NON_INTERACTIVE:-}" ]]; then
    echo -e "  Press ENTER to continue or Ctrl+C to exit."
    read -r
fi

# =============================================================================
# Collect credentials interactively
# =============================================================================

header "Collecting Your Credentials"

echo -e "${BOLD}── Server Information ──────────────────────────────────────${NC}"
echo -e "  This is used in agent documentation."
SERVER_IP="${SERVER_IP:-}"
if [[ -z "$SERVER_IP" ]]; then
    prompt "What is this server's IP address? (e.g. 123.45.67.89)"
    read -r SERVER_IP
fi
while [[ -z "$SERVER_IP" ]]; do
    prompt "IP address cannot be empty. Enter your droplet IP:"
    read -r SERVER_IP
done

echo ""
echo -e "${BOLD}── Gemini API Key ──────────────────────────────────────────${NC}"
echo -e "  Powers all 5 agents (Gemini models). Get yours at: Google AI Studio"
echo -e "  It looks like: AIzaSy..."
GEMINI_API_KEY="${GEMINI_API_KEY:-}"
if [[ -z "$GEMINI_API_KEY" ]]; then
    prompt "Paste your Gemini API key:"
    read -r GEMINI_API_KEY
fi
while [[ -z "$GEMINI_API_KEY" || "$GEMINI_API_KEY" != "AIzaSy"* ]]; do
    prompt "Key looks invalid. Paste your Gemini API key (starts with AIzaSy):"
    read -r GEMINI_API_KEY
done
GOOGLE_API_KEY="${GEMINI_API_KEY}"


echo ""
echo -e "${BOLD}── OpenAI API Key (for voice transcription) ────────────────${NC}"
echo -e "  Used to transcribe voice messages sent to your bots."
echo -e "  Get yours at: https://platform.openai.com/api-keys"
echo -e "  It looks like: sk-proj-... (press ENTER to skip — voice commands will be disabled)"
OPENAI_API_KEY="${OPENAI_API_KEY:-}"
if [[ -z "$OPENAI_API_KEY" && -z "${NON_INTERACTIVE:-}" ]]; then
    prompt "Paste your OpenAI API key (or press ENTER to skip):"
    read -r OPENAI_API_KEY
fi

echo ""
echo -e "${BOLD}── Portal Reports API URL ───────────────────────────────────${NC}"
echo -e "  All agent reports post here. Default local path:"
echo -e "  http://127.0.0.1:8000/api/reports/submit"
PORTAL_REPORTS_URL="${PORTAL_REPORTS_URL:-}"
if [[ -z "$PORTAL_REPORTS_URL" ]]; then
    prompt "Paste your Portal Reports API URL (default: http://127.0.0.1:8000/api/reports/submit):"
    read -r PORTAL_REPORTS_URL
fi
if [[ -z "$PORTAL_REPORTS_URL" ]]; then
    PORTAL_REPORTS_URL="http://127.0.0.1:8000/api/reports/submit"
fi
DISCORD_WEBHOOK_URL="${PORTAL_REPORTS_URL}"

echo ""
echo -e "${BOLD}── Telegram Bot Tokens ─────────────────────────────────────${NC}"
echo -e "  You need 5 bots. To create them:"
echo -e "  1. Open Telegram and search for @BotFather"
echo -e "  2. Send /newbot and follow the prompts for each bot"
echo -e "  3. Each token looks like: 8732631641:AAHu1OuUh8uRXqpZqH_6G77DMOwIAXVaRKU"
echo ""

TELEGRAM_TOKEN_HENRY="${TELEGRAM_TOKEN_HENRY:-dummy1}"
if [[ -z "$TELEGRAM_TOKEN_HENRY" && -z "${NON_INTERACTIVE:-}" ]]; then
    prompt "Henry bot token (Chief of Staff — your main command interface):"
    read -r TELEGRAM_TOKEN_HENRY
fi

TELEGRAM_TOKEN_CODER="${TELEGRAM_TOKEN_CODER:-dummy2}"
if [[ -z "$TELEGRAM_TOKEN_CODER" && -z "${NON_INTERACTIVE:-}" ]]; then
    prompt "Coder bot token (Software Engineer):"
    read -r TELEGRAM_TOKEN_CODER
fi

TELEGRAM_TOKEN_SCOUT="${TELEGRAM_TOKEN_SCOUT:-dummy3}"
if [[ -z "$TELEGRAM_TOKEN_SCOUT" && -z "${NON_INTERACTIVE:-}" ]]; then
    prompt "Scout bot token (Research Analyst):"
    read -r TELEGRAM_TOKEN_SCOUT
fi

TELEGRAM_TOKEN_WRITER="${TELEGRAM_TOKEN_WRITER:-dummy4}"
if [[ -z "$TELEGRAM_TOKEN_WRITER" && -z "${NON_INTERACTIVE:-}" ]]; then
    prompt "Writer bot token (Content Creator):"
    read -r TELEGRAM_TOKEN_WRITER
fi

TELEGRAM_TOKEN_WATCHER="${TELEGRAM_TOKEN_WATCHER:-dummy5}"
if [[ -z "$TELEGRAM_TOKEN_WATCHER" && -z "${NON_INTERACTIVE:-}" ]]; then
    prompt "Watcher bot token (System Monitor):"
    read -r TELEGRAM_TOKEN_WATCHER
fi

# Generate a random gateway token
GATEWAY_TOKEN=$(openssl rand -hex 24)

echo ""
echo -e "${GREEN}${BOLD}All credentials collected. Starting installation...${NC}\n"
sleep 2

# =============================================================================
# PHASE 1: Server preparation
# =============================================================================

header "Phase 1: Preparing Server"

# Swap (essential for 1GB RAM — 4GB gives a wide safety net on SSD droplets)
SWAP_SIZE="4G"
if [[ ! -f /swapfile ]]; then
    log "Creating ${SWAP_SIZE} swap..."
    fallocate -l "${SWAP_SIZE}" /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo 'vm.swappiness=10' >> /etc/sysctl.conf
    sysctl -p >> "$LOG_FILE" 2>&1
else
    # Resize existing swap to SWAP_SIZE if it's smaller
    CURRENT_SWAP_GB=$(free -g | awk '/^Swap:/{print $2}')
    DESIRED_SWAP_GB="${SWAP_SIZE//G/}"
    if [[ "$CURRENT_SWAP_GB" -lt "$DESIRED_SWAP_GB" ]]; then
        log "Resizing swap from ${CURRENT_SWAP_GB}GB to ${SWAP_SIZE}..."
        swapoff /swapfile
        fallocate -l "${SWAP_SIZE}" /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        log "Swap resized to ${SWAP_SIZE}"
    else
        log "Swap already ${CURRENT_SWAP_GB}GB (>= ${DESIRED_SWAP_GB}GB), no resize needed"
    fi
fi

# System updates
log "Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >> "$LOG_FILE" 2>&1
apt-get upgrade -y -qq >> "$LOG_FILE" 2>&1
apt-get install -y -qq curl wget git nano ufw python3 python3-pip python3-venv openssl >> "$LOG_FILE" 2>&1

# Timezone
timedatectl set-timezone America/Chicago >> "$LOG_FILE" 2>&1 || true

# Create clawuser
if ! id "$CLAW_USER" &>/dev/null; then
    log "Creating user: $CLAW_USER"
    useradd -m -s /bin/bash -G sudo "$CLAW_USER"
    echo "${CLAW_USER}:$(openssl rand -hex 16)" | chpasswd
else
    log "User $CLAW_USER already exists"
fi

# Firewall
log "Configuring firewall..."
ufw --force reset >> "$LOG_FILE" 2>&1
ufw default deny incoming >> "$LOG_FILE" 2>&1
ufw default allow outgoing >> "$LOG_FILE" 2>&1
ufw allow ssh >> "$LOG_FILE" 2>&1
ufw allow 80/tcp >> "$LOG_FILE" 2>&1       # Web portal
ufw allow 8050/tcp >> "$LOG_FILE" 2>&1   # Shiny dashboard
ufw --force enable >> "$LOG_FILE" 2>&1

# =============================================================================
# PHASE 2: Install Node.js and OpenClaw
# =============================================================================

header "Phase 2: Installing Node.js and OpenClaw"

if ! command -v node &>/dev/null; then
    log "Installing Node.js 24..."
    curl -fsSL https://deb.nodesource.com/setup_24.x | bash - >> "$LOG_FILE" 2>&1
    apt-get install -y -qq nodejs >> "$LOG_FILE" 2>&1
else
    log "Node.js already installed: $(node --version)"
fi

if ! command -v openclaw &>/dev/null; then
    log "Installing OpenClaw..."
    npm install -g openclaw >> "$LOG_FILE" 2>&1
else
    log "OpenClaw already installed: $(openclaw --version 2>/dev/null || echo 'unknown')"
fi

# =============================================================================
# PHASE 3: Set up agent workspaces
# =============================================================================

header "Phase 3: Setting Up Agent Workspaces"

mkdir -p "${OPENCLAW_DIR}/logs"
mkdir -p "${OPENCLAW_DIR}/canvas"

for AGENT in henry coder scout writer watcher; do
    mkdir -p "${OPENCLAW_DIR}/workspace-${AGENT}/skills"
    mkdir -p "${OPENCLAW_DIR}/workspace-${AGENT}/memory"
    mkdir -p "${OPENCLAW_DIR}/agents/${AGENT}/sessions"
    log "Workspace ready: ${AGENT}"
done

# Copy workspace configs from deploy package
if [[ -d "${DEPLOY_DIR}/configs" ]]; then
    for AGENT in henry coder scout writer watcher; do
        SRC="${DEPLOY_DIR}/configs/workspace-${AGENT}"
        DEST="${OPENCLAW_DIR}/workspace-${AGENT}"
        if [[ -d "$SRC" ]]; then
            cp -r "${SRC}/." "${DEST}/"
            log "Copied workspace files for ${AGENT}"
        fi
    done
fi

# Substitute student's Portal Reports API URL into all SOUL.md files
log "Configuring Portal Reports URL in agent personalities..."
for AGENT in henry coder scout writer watcher; do
    SOUL="${OPENCLAW_DIR}/workspace-${AGENT}/SOUL.md"
    if [[ -f "$SOUL" ]]; then
        sed -i "s|DISCORD_WEBHOOK_PLACEHOLDER|${PORTAL_REPORTS_URL}|g" "$SOUL"
    fi
done

# Substitute server IP into Henry's context
for AGENT in henry coder scout writer watcher; do
    SOUL="${OPENCLAW_DIR}/workspace-${AGENT}/SOUL.md"
    if [[ -f "$SOUL" ]]; then
        sed -i "s|YOUR_SERVER_IP|${SERVER_IP}|g" "$SOUL"
    fi
done

# Set audio enabled only when the user provided an OpenAI API key.
# Enabling audio with an empty key crashes the gateway on startup.
if [[ -n "${OPENAI_API_KEY}" ]]; then
    AUDIO_ENABLED="true"
else
    AUDIO_ENABLED="false"
fi

# =============================================================================
# PHASE 4: Write openclaw.json configuration
# =============================================================================

header "Phase 4: Writing OpenClaw Configuration"

cat > "${OPENCLAW_DIR}/openclaw.json" << CONFIGEOF
{
  "env": {
    "GEMINI_API_KEY": "${GEMINI_API_KEY}",
    "GOOGLE_API_KEY": "${GEMINI_API_KEY}",
    "OPENAI_API_KEY": "${OPENAI_API_KEY}",
    "PORTAL_REPORTS_URL": "${PORTAL_REPORTS_URL}",
    "DISCORD_WEBHOOK_URL": "${DISCORD_WEBHOOK_URL}"
  },
  "gateway": {
    "mode": "local",
    "http": {
      "endpoints": {
        "chatCompletions": {
          "enabled": true
        }
      }
    },
    "auth": {
      "mode": "none"
    }
  },
  "session": {
    "writeLock": {
      "acquireTimeoutMs": 300000,
      "maxHoldMs": 600000
    }
  },
  "acp": {
    "enabled": true,
    "allowedAgents": [
      "henry",
      "coder",
      "scout",
      "writer",
      "watcher"
    ],
    "maxConcurrentSessions": 5
  },
  "agents": {
    "defaults": {
      "model": { "primary": "google/gemini-2.5-flash" },
      "subagents": { "allowAgents": ["scout","writer","coder","watcher","henry"], "maxSpawnDepth": 1 },
      "memorySearch": {
        "provider": "gemini",
        "fallback": "none",
        "remote": {
          "batch": {
            "enabled": false
          }
        }
      }
    },
    "list": [
      { "id": "henry",   "name": "Henry",   "default": true,
        "workspace": "~/.openclaw/workspace-henry",   "agentDir": "~/.openclaw/agents/henry",   "model": "google/gemini-2.5-flash" },
      { "id": "coder",   "name": "Coder",
        "workspace": "~/.openclaw/workspace-coder",   "agentDir": "~/.openclaw/agents/coder",   "model": "google/gemini-2.5-flash" },
      { "id": "scout",   "name": "Scout",
        "workspace": "~/.openclaw/workspace-scout",   "agentDir": "~/.openclaw/agents/scout",   "model": "google/gemini-2.5-flash" },
      { "id": "writer",  "name": "Writer",
        "workspace": "~/.openclaw/workspace-writer",  "agentDir": "~/.openclaw/agents/writer",  "model": "google/gemini-2.5-flash" },
      { "id": "watcher", "name": "Watcher",
        "workspace": "~/.openclaw/workspace-watcher", "agentDir": "~/.openclaw/agents/watcher", "model": "google/gemini-2.5-flash" }
    ]
  },
  "models": {
    "providers": {
      "google": {
        "timeoutSeconds": 300
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": false
    }
  },
  "bindings": [],
  "memory": {
    "backend": "builtin"
  },
  "logging": {
    "level": "info",
    "file": "~/.openclaw/logs/openclaw.log"
  },
  "cron": { "enabled": true },
  "tools": {
    "exec": { "security": "full", "ask": "off" },
    "elevated": { "enabled": true },
    "media": { "audio": { "enabled": ${AUDIO_ENABLED}, "echoTranscript": true } },
    "message": { "crossContext": { "allowAcrossProviders": true } },
    "links": { "enabled": false }
  },
  "approvals": { "exec": { "enabled": false } },
  "plugins": {
    "entries": {
      "google":        { "enabled": true  },
      "anthropic":     { "enabled": false },
      "bonjour":       { "enabled": false },
      "acpx":          { "enabled": false },
      "browser":       { "enabled": false },
      "device-pair":   { "enabled": false },
      "phone-control": { "enabled": false },
      "talk-voice":    { "enabled": false }
    }
  }
}
CONFIGEOF
log "openclaw.json written"

# Write exec-approvals.json (allow all exec without interactive approval)
cat > "${OPENCLAW_DIR}/exec-approvals.json" << EAEOF
{
  "version": 1,
  "socket": {
    "path": "${OPENCLAW_DIR}/exec-approvals.sock",
    "token": "$(openssl rand -hex 24)"
  },
  "defaults": {
    "security": "full",
    "ask": "off"
  },
  "agents": {
    "*": {
      "security": "full",
      "ask": "off"
    }
  }
}
EAEOF
log "exec-approvals.json written (exec fully enabled for all agents)"

# =============================================================================
# PHASE 5: Set permissions
# =============================================================================

header "Phase 5: Setting File Permissions"

chown -R "${CLAW_USER}:${CLAW_USER}" "${OPENCLAW_DIR}"
find "${OPENCLAW_DIR}" -type d -exec chmod 700 {} \;
find "${OPENCLAW_DIR}" -type f -exec chmod 600 {} \;
chmod 755 "${OPENCLAW_DIR}"
log "Permissions set"

# =============================================================================
# PHASE 6: Install tmpfiles.d (ensures /tmp/openclaw dirs survive reboots)
# =============================================================================

header "Phase 6: Installing Symlink Repair Script and Temp Directories"

# Install the ExecStartPre script that repairs openclaw symlinks in
# plugin-runtime-deps before the gateway starts each time.
if [[ -f "${DEPLOY_DIR}/fix-openclaw-symlinks.sh" ]]; then
    cp "${DEPLOY_DIR}/fix-openclaw-symlinks.sh" /usr/local/bin/fix-openclaw-symlinks.sh
else
    cat > /usr/local/bin/fix-openclaw-symlinks.sh << 'SYMLINKEOF'
#!/bin/bash
for dir in /home/clawuser/.openclaw/plugin-runtime-deps/openclaw-*/node_modules; do
    [ -d "$dir" ] && ln -sfn /usr/lib/node_modules/openclaw "$dir/openclaw"
done
SYMLINKEOF
fi
chmod +x /usr/local/bin/fix-openclaw-symlinks.sh
log "Symlink repair script installed at /usr/local/bin/fix-openclaw-symlinks.sh"

# Install portal-post helper script for agents to post to Reports & Memos portal
cat > /usr/local/bin/portal-post << 'PORTALPOSTEOF'
#!/usr/bin/env python3
import sys, json, urllib.request
msg = sys.stdin.read().strip()
if not msg:
    sys.exit(0)
try:
    req = urllib.request.Request(
        "http://127.0.0.1:8000/api/reports/submit",
        data=json.dumps({"content": msg}).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )
    urllib.request.urlopen(req, timeout=5)
except Exception as e:
    sys.stderr.write(f"Failed to submit report locally: {e}\n")
PORTALPOSTEOF
chmod +x /usr/local/bin/portal-post
ln -sf /usr/local/bin/portal-post /usr/local/bin/discord-post
log "Portal-post script installed at /usr/local/bin/portal-post (discord-post symlinked)"

# Install portal-report skill for all agents
PORTAL_SKILL='# Portal Report Skill

Post a message to the Portal Reports & Memos screen.

## Method

Pipe your message to /usr/local/bin/portal-post:

```bash
cat << PORTAL_EOF | /usr/local/bin/portal-post
Your message content here...
PORTAL_EOF
```

Long messages (>2000 chars) are split automatically.

## IMPORTANT

Do NOT use message(channel="discord") - requires a Discord bot token not configured here.
Always use the pipe-to-script method above.
'
for AGENT in henry coder scout writer watcher; do
    mkdir -p "${OPENCLAW_DIR}/workspace-${AGENT}/skills"
    echo "$PORTAL_SKILL" > "${OPENCLAW_DIR}/workspace-${AGENT}/skills/portal-report.md"
    rm -f "${OPENCLAW_DIR}/workspace-${AGENT}/skills/portal-report.md"
done
log "Portal-report skill installed for all agents"

header "Phase 6b: Configuring Systemd Temp Directories"

cat > /etc/tmpfiles.d/openclaw.conf << TMPEOF
d /tmp/openclaw      0700 ${CLAW_USER} ${CLAW_USER} -
d /tmp/openclaw-1000 0700 ${CLAW_USER} ${CLAW_USER} -
TMPEOF
systemd-tmpfiles --create /etc/tmpfiles.d/openclaw.conf
log "Temp directories created and configured for auto-recreation on reboot"

# =============================================================================
# PHASE 7: Install systemd service
# =============================================================================

header "Phase 7: Installing OpenClaw Gateway Service"

if [[ -f "${DEPLOY_DIR}/openclaw.service" ]]; then
    cp "${DEPLOY_DIR}/openclaw.service" /etc/systemd/system/openclaw.service
else
cat > /etc/systemd/system/openclaw.service << 'SERVICEEOF'
[Unit]
Description=OpenClaw AI Agent Gateway — ClawInc
Documentation=https://openclaw.dev/docs
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=clawuser
Group=clawuser
WorkingDirectory=/home/clawuser
ExecStartPre=/usr/local/bin/fix-openclaw-symlinks.sh
ExecStart=/usr/bin/openclaw gateway run
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10
TimeoutStartSec=120
TimeoutStopSec=30

Environment=NODE_ENV=production
Environment=HOME=/home/clawuser
Environment="NODE_OPTIONS=--max-old-space-size=1024 --dns-result-order=ipv4first"
Environment=OPENCLAW_HANDSHAKE_TIMEOUT_MS=120000

NoNewPrivileges=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictNamespaces=true
RestrictSUIDSGID=true
MemoryDenyWriteExecute=false
SystemCallArchitectures=native

MemoryMax=1500M
MemoryHigh=1300M
TasksMax=64

StandardOutput=journal
StandardError=journal
SyslogIdentifier=openclaw

[Install]
WantedBy=multi-user.target
SERVICEEOF
fi

# Stop any pre-existing user-level gateway service running as root (wrong config)
for SVC in openclaw-gateway openclaw; do
    if systemctl --user is-active --quiet "$SVC" 2>/dev/null; then
        warn "Found user-level $SVC service running as root — stopping and disabling"
        systemctl --user stop "$SVC" 2>/dev/null || true
        systemctl --user disable "$SVC" 2>/dev/null || true
    fi
    USER_SVC="/root/.config/systemd/user/${SVC}.service"
    if [[ -f "$USER_SVC" ]]; then
        warn "Removing user-level service file: $USER_SVC"
        rm -f "$USER_SVC"
    fi
done

systemctl daemon-reload
systemctl enable openclaw
log "Systemd service installed and enabled"
# Install session file cleanup timer (prevents V8 OOM from large session history)
if [[ -f "${DEPLOY_DIR}/openclaw-session-cleanup.sh" ]]; then
    cp "${DEPLOY_DIR}/openclaw-session-cleanup.sh" /usr/local/bin/
    chmod +x /usr/local/bin/openclaw-session-cleanup.sh
    cp "${DEPLOY_DIR}/openclaw-session-cleanup.service" /etc/systemd/system/
    cp "${DEPLOY_DIR}/openclaw-session-cleanup.timer" /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable --now openclaw-session-cleanup.timer
    log "Session cleanup timer installed (runs every 2h)"
fi

# Apply Google client timeout/fetch patch to prevent 30s timeouts on long reasoning turns
log "Applying Google client timeout/fetch patch..."
cat > /tmp/patch_google_client.py << 'PATCHEOF'
import glob
import os
import re
import sys

dist_dir = "/usr/lib/node_modules/openclaw/dist"

# 1. Locate the file exporting buildGuardedModelFetch
fetch_guard_file = None
for path in glob.glob(os.path.join(dist_dir, "*.js")):
    try:
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        if "function buildGuardedModelFetch" in content:
            fetch_guard_file = os.path.basename(path)
            break
    except Exception:
        pass

if not fetch_guard_file:
    print("Error: Could not locate file exporting buildGuardedModelFetch!")
    sys.exit(1)

# 2. Locate the google client file (specifically for Google AI Studio)
google_client_file = None
for path in glob.glob(os.path.join(dist_dir, "google-*.js")):
    try:
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        if "//#region src/llm/providers/google.ts" in content:
            google_client_file = path
            break
    except Exception:
        pass

if not google_client_file:
    print("Error: Could not locate Google client file!")
    sys.exit(1)

# 3. Patch the Google client file
with open(google_client_file, "r", encoding="utf-8") as f:
    c = f.read()

# Make sure we don't patch it twice
if "buildGuardedModelFetch" in c:
    print("Already patched or buildGuardedModelFetch already imported.")
else:
    # Insert import statement
    import_target = 'import { GoogleGenAI } from "@google/genai";'
    import_repl = f'import {{ GoogleGenAI }} from "@google/genai";\nimport {{ m as buildGuardedModelFetch }} from "./{fetch_guard_file}";'
    
    if import_target in c:
        c = c.replace(import_target, import_repl, 1)
    else:
        import_target_sq = "import { GoogleGenAI } from '@google/genai';"
        import_repl_sq = f"import {{ GoogleGenAI }} from '@google/genai';\nimport {{ m as buildGuardedModelFetch }} from './{fetch_guard_file}';"
        c = c.replace(import_target_sq, import_repl_sq, 1)

    # Replace createClient function using regex
    match = re.search(r'function createClient\(model,\s*apiKey,\s*optionsHeaders\)\s*\{([\s\S]*?return\s+new\s+GoogleGenAI\(\{[\s\S]*?\}\);\s*\})', c)
    if match:
        original_body = match.group(0)
        
        patched_body = (
            "function createClient(model, apiKey, optionsHeaders) {\n"
            "\tconst httpOptions = {};\n"
            "\tif (model.baseUrl) {\n"
            "\t\thttpOptions.baseUrl = model.baseUrl;\n"
            "\t\thttpOptions.apiVersion = \"\";\n"
            "\t}\n"
            "\tconst timeoutMs = (model.timeoutSeconds ?? 300) * 1000;\n"
            "\treturn new GoogleGenAI({\n"
            "\t\tapiKey,\n"
            "\t\tbaseURL: httpOptions.baseUrl || undefined,\n"
            "\t\tapiVersion: httpOptions.apiVersion || undefined,\n"
            "\t\ttimeout: timeoutMs,\n"
            "\t\tfetch: buildGuardedModelFetch(model, timeoutMs),\n"
            "\t\tfetchOptions: (model.headers || optionsHeaders) ? {\n"
            "\t\t\theaders: {\n"
            "\t\t\t\t...model.headers,\n"
            "\t\t\t\t...optionsHeaders\n"
            "\t\t\t}\n"
            "\t\t} : undefined\n"
            "\t});\n"
            "}"
        )
        c = c.replace(original_body, patched_body, 1)
        print("Patched createClient successfully.")
    else:
        print("Warning: regex pattern for createClient did not match!")

    with open(google_client_file, "w", encoding="utf-8") as f:
        f.write(c)
    print("Patch successfully applied!")
PATCHEOF
python3 /tmp/patch_google_client.py
rm -f /tmp/patch_google_client.py


log "Starting OpenClaw gateway..."
systemctl start openclaw

# Wait up to 20 seconds for the gateway to become active
GW_READY=false
for i in $(seq 1 4); do
    sleep 5
    if systemctl is-active --quiet openclaw; then
        GW_READY=true
        break
    fi
done

if $GW_READY; then
    log "OpenClaw gateway is RUNNING ✓"
else
    warn "Gateway did not start within 20 seconds — checking logs..."
    journalctl -u openclaw -n 20 --no-pager | tee -a "$LOG_FILE"
fi

# =============================================================================
# PHASE 8: Validate configuration
# =============================================================================

header "Phase 8: Validating Configuration"

sleep 3
VALIDATE=$(su - "${CLAW_USER}" -c "openclaw config validate 2>&1" || echo "validation failed")
if echo "$VALIDATE" | grep -qi "valid"; then
    log "Config validation: PASSED ✓"
else
    warn "Config validation issue: $VALIDATE"
    warn "Run: su - clawuser -c 'openclaw config validate'"
fi

# =============================================================================
# PHASE 9: Install Shiny monitoring dashboard
# =============================================================================

header "Phase 9: Installing Monitoring Dashboard"

DASH_DIR="/opt/clawinc-dashboard"
mkdir -p "$DASH_DIR"

if [[ -f "${DEPLOY_DIR}/../dashboard/app.py" ]]; then
    cp "${DEPLOY_DIR}/../dashboard/app.py" "${DASH_DIR}/"
    cp "${DEPLOY_DIR}/../dashboard/requirements.txt" "${DASH_DIR}/" 2>/dev/null || true
    log "Dashboard files copied"
fi

if [[ -f "${DASH_DIR}/app.py" ]]; then
    python3 -m venv "${DASH_DIR}/venv" >> "$LOG_FILE" 2>&1
    "${DASH_DIR}/venv/bin/pip" install -q shiny psutil >> "$LOG_FILE" 2>&1

    if [[ -f "${DEPLOY_DIR}/clawinc-dashboard.service" ]]; then
        cp "${DEPLOY_DIR}/clawinc-dashboard.service" /etc/systemd/system/
    else
cat > /etc/systemd/system/clawinc-dashboard.service << 'DASHEOF'
[Unit]
Description=ClawInc Monitoring Dashboard
After=network.target openclaw.service
Wants=openclaw.service

[Service]
Type=simple
User=clawuser
Group=clawuser
WorkingDirectory=/opt/clawinc-dashboard
ExecStart=/opt/clawinc-dashboard/venv/bin/shiny run app.py --host 0.0.0.0 --port 8050
Restart=on-failure
RestartSec=10
Environment=HOME=/home/clawuser

StandardOutput=journal
StandardError=journal
SyslogIdentifier=clawinc-dashboard

[Install]
WantedBy=multi-user.target
DASHEOF
    fi

    chown -R "${CLAW_USER}:${CLAW_USER}" "$DASH_DIR"
    systemctl daemon-reload
    systemctl enable clawinc-dashboard
    systemctl start clawinc-dashboard
    sleep 3

    if systemctl is-active --quiet clawinc-dashboard; then
        log "Dashboard running at http://${SERVER_IP}:8050 ✓"
    else
        warn "Dashboard not running — check: journalctl -u clawinc-dashboard -n 20"
    fi
else
    warn "No dashboard/app.py found — skipping dashboard install"
fi

# =============================================================================
# PHASE 10: Set up cron jobs
# =============================================================================

header "Phase 10: Setting Up Automated Schedule"

# Write jobs.json directly — do NOT use 'openclaw cron add' here.
# The CLI spawns an openclaw-cron subprocess that JIT-compiles the full
# Node.js runtime (~60 s) before connecting to the gateway.  Running it
# inside a deploy script always races against the gateway's startup window
# and reliably hangs or errors.  Writing jobs.json directly is instant and
# survives service restarts unchanged.
#
# REQUIRED fields (learned the hard way):
#   sessionTarget: "isolated"  — without this the gateway crashes with
#       TypeError: Cannot read properties of undefined (reading 'startsWith')
#   delivery: {"mode":"none"}  — without this the gateway tries to deliver
#       results to the last Telegram session and fails with
#       "Delivering to Telegram requires target <chatId>"

CRON_DIR="${OPENCLAW_DIR}/cron"
mkdir -p "${CRON_DIR}"

if [[ -f "${DEPLOY_DIR}/configs/jobs.json" ]]; then
    cp "${DEPLOY_DIR}/configs/jobs.json" "${CRON_DIR}/jobs.json"
    log "Copied jobs.json from deploy package"
else
    # Fallback: write inline
    cat > "${CRON_DIR}/jobs.json" << 'JOBSEOF'
{
  "version": 1,
  "jobs": [
    {
      "id": "health-check-main",
      "name": "health-check",
      "agentId": "watcher",
      "sessionTarget": "isolated",
      "delivery": { "mode": "none" },
      "schedule": { "kind": "cron", "expr": "*/5 * * * *" },
      "payload": {
        "kind": "agentTurn",
        "message": "Run your health-check skill now. Check system resources (CPU, RAM, disk, swap), verify the OpenClaw gateway is running, and review recent error logs. If any metrics exceed warning thresholds, post an alert to the portal using your portal-report skill. Otherwise log the check quietly to your workspace."
      },
      "enabled": true,
      "createdAtMs": 1745535600000,
      "state": {}
    },
    {
      "id": "session-cleanup-hourly",
      "name": "session-cleanup",
      "agentId": "watcher",
      "sessionTarget": "isolated",
      "delivery": { "mode": "none" },
      "schedule": { "kind": "cron", "expr": "0 * * * *" },
      "payload": {
        "kind": "agentTurn",
        "message": "Run your session-cleanup skill now. Archive old sessions, clean up temporary files, and ensure disk usage stays healthy. IMPORTANT: Do not call the update_goal tool as this is an automated system task."
      },
      "enabled": true,
      "createdAtMs": 1745535600000,
      "state": {}
    },
    {
      "id": "morning-research-daily",
      "name": "morning-research",
      "agentId": "scout",
      "sessionTarget": "isolated",
      "delivery": { "mode": "none" },
      "schedule": { "kind": "cron", "expr": "0 8 * * *" },
      "payload": {
        "kind": "agentTurn",
        "message": "Run your news-digest skill. Search for the latest trending topics in aesthetics, medspa marketing, local Scottsdale competitor medspas (pricing for Botox, fillers, Sculptra), patient feedback, and updates on Cherry or CareCredit financing plans. Write a structured briefing with comparison tables and key competitive findings. Save the briefing to your memory. Then post a signed summary to the portal using your portal-report skill."
      },
      "enabled": true,
      "createdAtMs": 1745535600000,
      "state": {}
    },
    {
      "id": "daily-memo-writer",
      "name": "daily-memo",
      "agentId": "writer",
      "sessionTarget": "isolated",
      "delivery": { "mode": "none" },
      "schedule": { "kind": "cron", "expr": "0 9 * * *" },
      "payload": {
        "kind": "agentTurn",
        "message": "Run your write-memo skill. Search Scout's memory for today's competitor and aesthetics research briefing. Synthesize it into a polished, high-end operational memo for Sumar Kasik, RN. Structure it with sections: Competitor Price Shifts, Aesthetic Market Opportunities, Proposed Homepage Copy adjustments, and Social Media/Outreach Ideas. Save to memory. Post the memo using your portal-report skill."
      },
      "enabled": true,
      "createdAtMs": 1745535600000,
      "state": {}
    },
    {
      "id": "nightly-rnd-henry",
      "name": "nightly-rnd",
      "agentId": "henry",
      "sessionTarget": "isolated",
      "delivery": { "mode": "none" },
      "schedule": { "kind": "cron", "expr": "0 23 * * *" },
      "payload": {
        "kind": "agentTurn",
        "message": "Run your rnd-meeting skill. Review today's memo from Writer, competitor research from Scout, and coding deliverables from Coder. Analyze gaps in Derma Art's branding, site responsiveness, or patient outreach. Formulate strategic recommendations for Sumar Kasik, RN. Post the retrospective summary using your portal-report skill. IMPORTANT: Do not call the update_goal tool as this is an automated system task."
      },
      "enabled": true,
      "createdAtMs": 1745535600000,
      "state": {}
    }
  ]
}
JOBSEOF
    log "jobs.json written inline"
fi

# Write a clean jobs-state.json so there is no accumulated error backoff
# from a previous install attempt.
cat > "${CRON_DIR}/jobs-state.json" << 'STATEEOF'
{ "version": 1, "jobs": {} }
STATEEOF

chown -R "${CLAW_USER}:${CLAW_USER}" "${CRON_DIR}"
chmod 600 "${CRON_DIR}/jobs.json" "${CRON_DIR}/jobs-state.json"
log "Cron jobs configured via jobs.json (5 scheduled tasks)"

# =============================================================================
# FINAL: Summary
# =============================================================================

header "Installation Complete 🎉"

echo -e "${GREEN}${BOLD}"
echo "  ✓ OpenClaw gateway running"
echo "  ✓ 5 agents configured: Henry, Coder, Scout, Writer, Watcher"
echo "  ✓ Telegram bots connected"
echo "  ✓ Portal reports URL configured"
echo "  ✓ Exec approvals disabled (agents can run code freely)"
echo "  ✓ 6 cron jobs scheduled"
echo -e "${NC}"
echo -e "${BOLD}  Your ClawInc company is live at:${NC}"
echo -e "  Server:    ${SERVER_IP}"
echo -e "  Dashboard: http://${SERVER_IP}:8050"
echo ""
echo -e "${BOLD}  Next steps:${NC}"
echo -e "  1. Open Telegram and search for your Henry bot"
echo -e "  2. Send a message — Henry will respond within seconds"
echo -e "  3. Check your Portal Reports & Memos screen for the response"
echo ""
echo -e "${BOLD}  Useful commands:${NC}"
echo -e "  systemctl status openclaw              # Check gateway status"
echo -e "  journalctl -u openclaw -f              # Watch live logs"
echo -e "  su - clawuser -c 'openclaw status'    # Agent status"
echo ""
echo "  Full deploy log: $LOG_FILE"
echo ""


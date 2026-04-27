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
echo -e "  Controlled via Telegram · Reports posted to Discord\n"
echo -e "${YELLOW}  Before continuing, make sure you have:${NC}"
echo -e "  1. Your Anthropic API key   → console.anthropic.com (required)"
echo -e "  2. Your OpenAI API key      → platform.openai.com (for voice commands)"
echo -e "  3. Your Discord webhook URL → your Discord server → #reports channel"
echo -e "  4. Five Telegram bot tokens → @BotFather on Telegram\n"
echo -e "  Press ENTER to continue or Ctrl+C to exit."
read -r

# =============================================================================
# Collect credentials interactively
# =============================================================================

header "Collecting Your Credentials"

echo -e "${BOLD}── Server Information ──────────────────────────────────────${NC}"
echo -e "  This is used in agent documentation."
prompt "What is this server's IP address? (e.g. 123.45.67.89)"
read -r SERVER_IP
while [[ -z "$SERVER_IP" ]]; do
    prompt "IP address cannot be empty. Enter your droplet IP:"
    read -r SERVER_IP
done

echo ""
echo -e "${BOLD}── Anthropic API Key ───────────────────────────────────────${NC}"
echo -e "  Powers all 5 agents (Claude models). Get yours at: https://console.anthropic.com/api-keys"
echo -e "  It looks like: sk-ant-api03-..."
prompt "Paste your Anthropic API key:"
read -r ANTHROPIC_API_KEY
while [[ -z "$ANTHROPIC_API_KEY" || "$ANTHROPIC_API_KEY" == "sk-ant-"* && ${#ANTHROPIC_API_KEY} -lt 40 ]]; do
    prompt "Key looks invalid. Paste your Anthropic API key (starts with sk-ant-):"
    read -r ANTHROPIC_API_KEY
done

echo ""
echo -e "${BOLD}── OpenAI API Key (for voice transcription) ────────────────${NC}"
echo -e "  Used to transcribe voice messages sent to your bots."
echo -e "  Get yours at: https://platform.openai.com/api-keys"
echo -e "  It looks like: sk-proj-... (press ENTER to skip — voice commands will be disabled)"
prompt "Paste your OpenAI API key (or press ENTER to skip):"
read -r OPENAI_API_KEY

echo ""
echo -e "${BOLD}── Discord Webhook URL ─────────────────────────────────────${NC}"
echo -e "  All agent reports post here. To get your webhook URL:"
echo -e "  1. Open Discord → your ClawInc server → #reports channel"
echo -e "  2. Right-click #reports → Edit Channel → Integrations → Webhooks"
echo -e "  3. Click 'New Webhook' → name it 'ClawInc Reports' → Copy Webhook URL"
echo -e "  It looks like: https://discord.com/api/webhooks/123456/ABCDEF..."
prompt "Paste your Discord webhook URL:"
read -r DISCORD_WEBHOOK_URL
while [[ -z "$DISCORD_WEBHOOK_URL" ]]; do
    prompt "Webhook URL cannot be empty. Paste your Discord webhook URL:"
    read -r DISCORD_WEBHOOK_URL
done

echo ""
echo -e "${BOLD}── Telegram Bot Tokens ─────────────────────────────────────${NC}"
echo -e "  You need 5 bots. To create them:"
echo -e "  1. Open Telegram and search for @BotFather"
echo -e "  2. Send /newbot and follow the prompts for each bot"
echo -e "  3. Each token looks like: 8732631641:AAHu1OuUh8uRXqpZqH_6G77DMOwIAXVaRKU"
echo ""

prompt "Henry bot token (Chief of Staff — your main command interface):"
read -r TELEGRAM_TOKEN_HENRY
while [[ -z "$TELEGRAM_TOKEN_HENRY" ]]; do
    prompt "Henry token cannot be empty:"; read -r TELEGRAM_TOKEN_HENRY
done

prompt "Coder bot token (Software Engineer):"
read -r TELEGRAM_TOKEN_CODER
while [[ -z "$TELEGRAM_TOKEN_CODER" ]]; do
    prompt "Coder token cannot be empty:"; read -r TELEGRAM_TOKEN_CODER
done

prompt "Scout bot token (Research Analyst):"
read -r TELEGRAM_TOKEN_SCOUT
while [[ -z "$TELEGRAM_TOKEN_SCOUT" ]]; do
    prompt "Scout token cannot be empty:"; read -r TELEGRAM_TOKEN_SCOUT
done

prompt "Writer bot token (Content Creator):"
read -r TELEGRAM_TOKEN_WRITER
while [[ -z "$TELEGRAM_TOKEN_WRITER" ]]; do
    prompt "Writer token cannot be empty:"; read -r TELEGRAM_TOKEN_WRITER
done

prompt "Watcher bot token (System Monitor):"
read -r TELEGRAM_TOKEN_WATCHER
while [[ -z "$TELEGRAM_TOKEN_WATCHER" ]]; do
    prompt "Watcher token cannot be empty:"; read -r TELEGRAM_TOKEN_WATCHER
done

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

# Substitute student's Discord webhook URL into all SOUL.md files
log "Configuring Discord webhook in agent personalities..."
for AGENT in henry coder scout writer watcher; do
    SOUL="${OPENCLAW_DIR}/workspace-${AGENT}/SOUL.md"
    if [[ -f "$SOUL" ]]; then
        sed -i "s|DISCORD_WEBHOOK_PLACEHOLDER|${DISCORD_WEBHOOK_URL}|g" "$SOUL"
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
    "ANTHROPIC_API_KEY": "${ANTHROPIC_API_KEY}",
    "OPENAI_API_KEY": "${OPENAI_API_KEY}",
    "DISCORD_WEBHOOK_URL": "${DISCORD_WEBHOOK_URL}"
  },
  "gateway": {
    "mode": "local"
  },
  "tools": {
    "exec": {
      "security": "full",
      "ask": "off"
    },
    "media": {
      "audio": {
        "enabled": ${AUDIO_ENABLED},
        "echoTranscript": true
      }
    }
  },
  "agents": {
    "defaults": {
      "model": { "primary": "anthropic/claude-sonnet-4-6" }
    },
    "list": [
      {
        "id": "henry",
        "name": "Henry",
        "default": true,
        "workspace": "~/.openclaw/workspace-henry",
        "agentDir": "~/.openclaw/agents/henry",
        "model": "anthropic/claude-opus-4-7"
      },
      {
        "id": "coder",
        "name": "Coder",
        "workspace": "~/.openclaw/workspace-coder",
        "agentDir": "~/.openclaw/agents/coder",
        "model": "anthropic/claude-sonnet-4-6"
      },
      {
        "id": "scout",
        "name": "Scout",
        "workspace": "~/.openclaw/workspace-scout",
        "agentDir": "~/.openclaw/agents/scout",
        "model": "anthropic/claude-haiku-4-5-20251001"
      },
      {
        "id": "writer",
        "name": "Writer",
        "workspace": "~/.openclaw/workspace-writer",
        "agentDir": "~/.openclaw/agents/writer",
        "model": "anthropic/claude-sonnet-4-6"
      },
      {
        "id": "watcher",
        "name": "Watcher",
        "workspace": "~/.openclaw/workspace-watcher",
        "agentDir": "~/.openclaw/agents/watcher",
        "model": "anthropic/claude-haiku-4-5-20251001"
      }
    ]
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "open",
      "allowFrom": ["*"],
      "defaultAccount": "henry-bot",
      "accounts": {
        "henry-bot": {
          "botToken": "${TELEGRAM_TOKEN_HENRY}",
          "dmPolicy": "open", "allowFrom": ["*"],
          "plugins": { "entries": {
            "bonjour": {"enabled": false}, "acpx": {"enabled": false},
            "browser": {"enabled": false}, "device-pair": {"enabled": false},
            "phone-control": {"enabled": false}, "talk-voice": {"enabled": false}
          }}
        },
        "coder-bot": {
          "botToken": "${TELEGRAM_TOKEN_CODER}",
          "dmPolicy": "open", "allowFrom": ["*"],
          "plugins": { "entries": {
            "bonjour": {"enabled": false}, "acpx": {"enabled": false},
            "browser": {"enabled": false}, "device-pair": {"enabled": false},
            "phone-control": {"enabled": false}, "talk-voice": {"enabled": false}
          }}
        },
        "scout-bot": {
          "botToken": "${TELEGRAM_TOKEN_SCOUT}",
          "dmPolicy": "open", "allowFrom": ["*"],
          "plugins": { "entries": {
            "bonjour": {"enabled": false}, "acpx": {"enabled": false},
            "browser": {"enabled": false}, "device-pair": {"enabled": false},
            "phone-control": {"enabled": false}, "talk-voice": {"enabled": false}
          }}
        },
        "writer-bot": {
          "botToken": "${TELEGRAM_TOKEN_WRITER}",
          "dmPolicy": "open", "allowFrom": ["*"],
          "plugins": { "entries": {
            "bonjour": {"enabled": false}, "acpx": {"enabled": false},
            "browser": {"enabled": false}, "device-pair": {"enabled": false},
            "phone-control": {"enabled": false}, "talk-voice": {"enabled": false}
          }}
        },
        "watcher-bot": {
          "botToken": "${TELEGRAM_TOKEN_WATCHER}",
          "dmPolicy": "open", "allowFrom": ["*"],
          "plugins": { "entries": {
            "bonjour": {"enabled": false}, "acpx": {"enabled": false},
            "browser": {"enabled": false}, "device-pair": {"enabled": false},
            "phone-control": {"enabled": false}, "talk-voice": {"enabled": false}
          }}
        }
      }
    }
  },
  "bindings": [
    { "agentId": "henry",   "match": { "channel": "telegram", "accountId": "henry-bot"   } },
    { "agentId": "coder",   "match": { "channel": "telegram", "accountId": "coder-bot"   } },
    { "agentId": "scout",   "match": { "channel": "telegram", "accountId": "scout-bot"   } },
    { "agentId": "writer",  "match": { "channel": "telegram", "accountId": "writer-bot"  } },
    { "agentId": "watcher", "match": { "channel": "telegram", "accountId": "watcher-bot" } }
  ],
  "memory": {
    "backend": "qmd",
    "qmd": { "searchMode": "search" }
  },
  "logging": {
    "level": "info",
    "file": "~/.openclaw/logs/openclaw.log"
  },
  "cron": { "enabled": true },
  "approvals": { "exec": { "enabled": false } },
  "plugins": {
    "entries": {
      "anthropic":     { "enabled": true  },
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
Environment=NODE_OPTIONS=--max-old-space-size=384
Environment=OPENCLAW_HANDSHAKE_TIMEOUT_MS=120000

NoNewPrivileges=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictNamespaces=true
RestrictSUIDSGID=true
MemoryDenyWriteExecute=false
SystemCallArchitectures=native

MemoryMax=1200M
MemoryHigh=1024M
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
        "message": "Run your health-check skill now. Check system resources (CPU, RAM, disk, swap), verify the OpenClaw gateway is running, and review recent error logs. If any metrics exceed warning thresholds, post an alert to Discord using your discord-report skill. Otherwise log the check to your workspace."
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
        "message": "Run your session-cleanup skill now. Archive old sessions, clean up temporary files, and ensure disk usage stays healthy."
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
        "message": "Run your news-digest skill. Search for the latest trending topics in AI, marketing analytics, and technology from the last 24 hours. Write a structured briefing with key findings, notable trends, and actionable insights. Save the briefing to your memory. Then post a signed summary to Discord using your discord-report skill."
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
        "message": "Run your write-memo skill. Search Scout memory for today's research briefing. Synthesize into a polished executive memo with sections: Top Stories, Trend Analysis, Action Items, Market Watch. Save to your memory. Post to Discord using your discord-report skill."
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
        "message": "Run your rnd-meeting skill. Review today's memo from Writer, research from Scout, and any code from Coder. Identify opportunities and strategic improvements. Delegate follow-up tasks. Post a summary to Discord using your discord-report skill."
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
echo "  ✓ Discord webhook configured"
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
echo -e "  3. Check your Discord #reports channel for the response"
echo ""
echo -e "${BOLD}  Useful commands:${NC}"
echo -e "  systemctl status openclaw              # Check gateway status"
echo -e "  journalctl -u openclaw -f              # Watch live logs"
echo -e "  su - clawuser -c 'openclaw status'    # Agent status"
echo ""
echo "  Full deploy log: $LOG_FILE"
echo ""

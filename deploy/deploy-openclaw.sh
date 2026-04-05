#!/usr/bin/env bash
# =============================================================================
# deploy-openclaw.sh — ClawInc Multi-Agent Company Deployment
# =============================================================================
# Deploys a full OpenClaw multi-agent system on Ubuntu 24.04 (DigitalOcean)
#
# Usage:
#   1. Edit the CONFIGURATION section below with your API keys and tokens
#   2. SCP this script + the configs/ directory to the server:
#        scp -r deploy/ root@137.184.15.207:/root/deploy/
#   3. SSH in and run:
#        ssh root@137.184.15.207
#        chmod +x /root/deploy/deploy-openclaw.sh
#        /root/deploy/deploy-openclaw.sh
#
# Server: YOUR_DROPLET_IP — 1 vCPU, 1GB RAM, 24GB disk, Ubuntu 24.04
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION — EDIT THESE BEFORE RUNNING
# =============================================================================

# Anthropic API Key (required — powers all agents)
# Get yours at: https://console.anthropic.com/api-keys
ANTHROPIC_API_KEY="YOUR_ANTHROPIC_API_KEY"

# OpenAI API Key (optional — backup/alternative provider)
OPENAI_API_KEY="YOUR_OPENAI_API_KEY"

# Telegram Bot Tokens (create 4 bots via @BotFather on Telegram)
# See Student_Setup_Guide_ClawInc.Rmd Part 2 for instructions
TELEGRAM_TOKEN_HENRY="YOUR_TELEGRAM_BOT_TOKEN_HENRY"
TELEGRAM_TOKEN_CODER="YOUR_TELEGRAM_BOT_TOKEN_CODER"
TELEGRAM_TOKEN_SCOUT="YOUR_TELEGRAM_BOT_TOKEN_SCOUT"
TELEGRAM_TOKEN_WRITER="YOUR_TELEGRAM_BOT_TOKEN_WRITER"
TELEGRAM_TOKEN_WATCHER="YOUR_TELEGRAM_BOT_TOKEN_WATCHER"

# Discord Webhook URL (paste the webhook URL from your Discord server channel settings)
# All agent reports will be posted here, signed by each agent
# Leave blank to disable Discord delivery
DISCORD_WEBHOOK_URL="YOUR_DISCORD_WEBHOOK_URL"

# Gateway Auth Token (auto-generated if left as default)
GATEWAY_TOKEN="AUTO"

# Non-root user to create
CLAW_USER="clawuser"

# Timezone
TIMEZONE="America/Chicago"

# =============================================================================
# DO NOT EDIT BELOW THIS LINE (unless you know what you're doing)
# =============================================================================

DEPLOY_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENCLAW_DIR="/home/${CLAW_USER}/.openclaw"
LOG_FILE="/var/log/openclaw-deploy.log"
NODESOURCE_VERSION="24"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log()    { echo -e "${GREEN}[✓]${NC} $*" | tee -a "$LOG_FILE"; }
warn()   { echo -e "${YELLOW}[!]${NC} $*" | tee -a "$LOG_FILE"; }
error()  { echo -e "${RED}[✗]${NC} $*" | tee -a "$LOG_FILE"; }
header() { echo -e "\n${BLUE}========================================${NC}" | tee -a "$LOG_FILE"
           echo -e "${BLUE}  $*${NC}" | tee -a "$LOG_FILE"
           echo -e "${BLUE}========================================${NC}\n" | tee -a "$LOG_FILE"; }

# Pre-flight checks
preflight() {
    header "Pre-Flight Checks"

    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
        exit 1
    fi

    if [[ "$ANTHROPIC_API_KEY" == "YOUR_ANTHROPIC_API_KEY" ]]; then
        error "You must set ANTHROPIC_API_KEY before running this script!"
        error "Edit the CONFIGURATION section at the top of this file."
        exit 1
    fi

    if [[ "$TELEGRAM_TOKEN_HENRY" == "YOUR_TELEGRAM_BOT_TOKEN_HENRY" ]]; then
        warn "Telegram tokens not configured. Agents will not be reachable via Telegram."
        warn "You can update tokens later in ${OPENCLAW_DIR}/openclaw.json"
        read -p "Continue without Telegram? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Generate gateway token if set to AUTO
    if [[ "$GATEWAY_TOKEN" == "AUTO" ]]; then
        GATEWAY_TOKEN=$(openssl rand -hex 32)
        log "Generated gateway auth token: ${GATEWAY_TOKEN:0:8}...${GATEWAY_TOKEN: -8}"
        log "SAVE THIS TOKEN — you'll need it for Mission Control"
        echo "$GATEWAY_TOKEN" > /root/.openclaw-gateway-token
        chmod 600 /root/.openclaw-gateway-token
        log "Token also saved to /root/.openclaw-gateway-token"
    fi

    log "Pre-flight checks passed"
}

# =============================================================================
# PHASE 1: Server Preparation
# =============================================================================
phase1_server_prep() {
    header "Phase 1: Server Preparation"

    # 1a. Create swap space (critical for 1GB RAM)
    if [[ ! -f /swapfile ]]; then
        log "Creating 2GB swap file..."
        fallocate -l 2G /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        if ! grep -q '/swapfile' /etc/fstab; then
            echo '/swapfile none swap sw 0 0' >> /etc/fstab
        fi
        log "Swap created and enabled"
    else
        log "Swap file already exists"
        if ! swapon --show | grep -q '/swapfile'; then
            swapon /swapfile
            log "Swap re-enabled"
        fi
    fi

    # Tune swappiness for low-RAM server
    sysctl vm.swappiness=60 > /dev/null
    if ! grep -q 'vm.swappiness' /etc/sysctl.conf; then
        echo 'vm.swappiness=60' >> /etc/sysctl.conf
    fi

    # 1b. System updates & dependencies
    log "Updating system packages..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get upgrade -y -qq
    apt-get install -y -qq git curl build-essential ufw software-properties-common \
        jq htop tmux unzip wget ca-certificates gnupg

    # 1c. Set timezone
    timedatectl set-timezone "$TIMEZONE" 2>/dev/null || true
    log "Timezone set to $TIMEZONE"

    # 1d. Set hostname
    hostnamectl set-hostname ClawInc 2>/dev/null || true
    log "Hostname set to ClawInc"

    # 1e. Create non-root user
    if ! id "$CLAW_USER" &>/dev/null; then
        adduser --disabled-password --gecos "OpenClaw Service User" "$CLAW_USER"
        usermod -aG sudo "$CLAW_USER"
        # Allow sudo without password for service management
        echo "${CLAW_USER} ALL=(ALL) NOPASSWD: /bin/systemctl restart openclaw, /bin/systemctl status openclaw, /bin/journalctl -u openclaw*" > /etc/sudoers.d/openclaw
        chmod 440 /etc/sudoers.d/openclaw
        log "Created user: ${CLAW_USER}"
    else
        log "User ${CLAW_USER} already exists"
    fi

    # 1f. Firewall setup
    ufw --force reset > /dev/null 2>&1
    ufw default deny incoming > /dev/null
    ufw default allow outgoing > /dev/null
    ufw allow ssh > /dev/null
    ufw allow 8050/tcp > /dev/null
    ufw --force enable > /dev/null
    log "Firewall configured — SSH (22) and dashboard (8050) open"

    # Create project directory
    mkdir -p /home/${CLAW_USER}/projects
    chown ${CLAW_USER}:${CLAW_USER} /home/${CLAW_USER}/projects

    log "Phase 1 complete"
}

# =============================================================================
# PHASE 2: Node.js & OpenClaw Installation
# =============================================================================
phase2_install() {
    header "Phase 2: Node.js & OpenClaw Installation"

    # 2a. Install Node.js
    if ! command -v node &>/dev/null || [[ "$(node --version | cut -d. -f1 | tr -d v)" -lt "$NODESOURCE_VERSION" ]]; then
        log "Installing Node.js ${NODESOURCE_VERSION}..."
        curl -fsSL "https://deb.nodesource.com/setup_${NODESOURCE_VERSION}.x" | bash - > /dev/null 2>&1
        apt-get install -y -qq nodejs
        log "Node.js $(node --version) installed"
    else
        log "Node.js $(node --version) already installed"
    fi

    # 2b. Install OpenClaw globally
    log "Installing OpenClaw..."
    npm install -g openclaw@latest 2>&1 | tail -1
    log "OpenClaw $(openclaw --version 2>/dev/null || echo 'installed') ready"

    # Make sure clawuser can use global npm packages
    mkdir -p /home/${CLAW_USER}/.npm-global
    chown -R ${CLAW_USER}:${CLAW_USER} /home/${CLAW_USER}/.npm-global

    log "Phase 2 complete"
}

# =============================================================================
# PHASE 3: Multi-Agent Configuration
# =============================================================================
phase3_configure() {
    header "Phase 3: Multi-Agent Configuration"

    # 3a. Create workspace directory structure
    log "Creating workspace directories..."
    local AGENTS=("henry" "coder" "scout" "writer" "watcher")
    for agent in "${AGENTS[@]}"; do
        mkdir -p "${OPENCLAW_DIR}/workspace-${agent}/skills"
        mkdir -p "${OPENCLAW_DIR}/workspace-${agent}/memory"
        mkdir -p "${OPENCLAW_DIR}/agents/${agent}"
    done
    mkdir -p "${OPENCLAW_DIR}/logs"
    mkdir -p /tmp/openclaw

    # 3b. Copy configuration files from deploy bundle
    log "Installing configuration files..."

    if [[ -d "${DEPLOY_DIR}/configs" ]]; then
        # Copy openclaw.json
        cp "${DEPLOY_DIR}/configs/openclaw.json" "${OPENCLAW_DIR}/openclaw.json"

        # Copy workspace files for each agent
        for agent in "${AGENTS[@]}"; do
            if [[ -d "${DEPLOY_DIR}/configs/workspace-${agent}" ]]; then
                cp -r "${DEPLOY_DIR}/configs/workspace-${agent}/"* "${OPENCLAW_DIR}/workspace-${agent}/"
                log "  Installed workspace-${agent}"
            fi
        done
    else
        error "Config directory not found at ${DEPLOY_DIR}/configs"
        error "Make sure you uploaded the full deploy/ directory"
        exit 1
    fi

    # 3c. Substitute API keys and tokens in openclaw.json
    log "Configuring API keys and tokens..."
    local CONFIG="${OPENCLAW_DIR}/openclaw.json"

    sed -i "s|YOUR_ANTHROPIC_API_KEY|${ANTHROPIC_API_KEY}|g" "$CONFIG"
    sed -i "s|YOUR_OPENAI_API_KEY|${OPENAI_API_KEY}|g" "$CONFIG"
    sed -i "s|YOUR_TELEGRAM_BOT_TOKEN_HENRY|${TELEGRAM_TOKEN_HENRY}|g" "$CONFIG"
    sed -i "s|YOUR_TELEGRAM_BOT_TOKEN_CODER|${TELEGRAM_TOKEN_CODER}|g" "$CONFIG"
    sed -i "s|YOUR_TELEGRAM_BOT_TOKEN_SCOUT|${TELEGRAM_TOKEN_SCOUT}|g" "$CONFIG"
    sed -i "s|YOUR_TELEGRAM_BOT_TOKEN_WRITER|${TELEGRAM_TOKEN_WRITER}|g" "$CONFIG"
    sed -i "s|YOUR_TELEGRAM_BOT_TOKEN_WATCHER|${TELEGRAM_TOKEN_WATCHER}|g" "$CONFIG"
    sed -i "s|YOUR_DISCORD_WEBHOOK_URL|${DISCORD_WEBHOOK_URL}|g" "$CONFIG"
    sed -i "s|YOUR_GATEWAY_AUTH_TOKEN_REPLACE_ME_WITH_50_PLUS_CHAR_RANDOM_STRING|${GATEWAY_TOKEN}|g" "$CONFIG"

    log "API keys and tokens configured"
    log "Phase 3 complete"
}

# =============================================================================
# PHASE 7: Security Hardening (run before starting services)
# =============================================================================
phase7_security() {
    header "Phase 7: Security Hardening"

    # Set ownership
    chown -R ${CLAW_USER}:${CLAW_USER} "${OPENCLAW_DIR}"
    chown -R ${CLAW_USER}:${CLAW_USER} /home/${CLAW_USER}/projects
    chown -R ${CLAW_USER}:${CLAW_USER} /tmp/openclaw

    # Set directory permissions (700 = owner only)
    find "${OPENCLAW_DIR}" -type d -exec chmod 700 {} \;

    # Set file permissions (600 = owner read/write only)
    find "${OPENCLAW_DIR}" -type f -exec chmod 600 {} \;

    # Make skill scripts executable if any exist
    find "${OPENCLAW_DIR}" -name "*.sh" -exec chmod 700 {} \;

    # Protect the config file specifically
    chmod 600 "${OPENCLAW_DIR}/openclaw.json"

    # Set mDNS to minimal
    if [[ -f /etc/systemd/resolved.conf ]]; then
        sed -i 's/^#*MulticastDNS=.*/MulticastDNS=no/' /etc/systemd/resolved.conf
        systemctl restart systemd-resolved 2>/dev/null || true
    fi

    log "File permissions hardened (700 dirs, 600 files)"
    log "Gateway bound to 127.0.0.1 only (no public exposure)"
    log "Access via SSH tunnel: ssh -L 3000:localhost:3000 -L 4200:localhost:4200 root@137.184.15.207"
    log "Phase 7 complete"
}

# =============================================================================
# PHASE 6: Systemd Service Setup
# =============================================================================
phase6_systemd() {
    header "Phase 6: Systemd Service Setup"

    # Install systemd service
    if [[ -f "${DEPLOY_DIR}/openclaw.service" ]]; then
        cp "${DEPLOY_DIR}/openclaw.service" /etc/systemd/system/openclaw.service
    else
        # Write inline if service file not in bundle
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
ExecStart=/usr/bin/openclaw gateway run
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10
TimeoutStartSec=30
TimeoutStopSec=30
Environment=NODE_ENV=production
Environment=HOME=/home/clawuser
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/home/clawuser/.openclaw /tmp/openclaw
PrivateTmp=false
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictNamespaces=true
RestrictSUIDSGID=true
MemoryDenyWriteExecute=false
SystemCallArchitectures=native
MemoryMax=512M
MemoryHigh=384M
TasksMax=64
StandardOutput=journal
StandardError=journal
SyslogIdentifier=openclaw

[Install]
WantedBy=multi-user.target
SERVICEEOF
    fi

    # Install tmpfiles.d config so /tmp/openclaw* dirs are created at every boot
    # (required for systemd ReadWritePaths namespace setup)
    if [[ -f "${DEPLOY_DIR}/openclaw-tmpfiles.conf" ]]; then
        cp "${DEPLOY_DIR}/openclaw-tmpfiles.conf" /etc/tmpfiles.d/openclaw.conf
    else
        cat > /etc/tmpfiles.d/openclaw.conf << 'TMPEOF'
d /tmp/openclaw      0700 clawuser clawuser -
d /tmp/openclaw-1000 0700 clawuser clawuser -
TMPEOF
    fi
    systemd-tmpfiles --create /etc/tmpfiles.d/openclaw.conf
    log "Tmpfiles config installed — /tmp/openclaw dirs created"

    systemctl daemon-reload
    systemctl enable openclaw
    log "Systemd service installed and enabled"

    # Start the gateway
    log "Starting OpenClaw gateway..."
    systemctl start openclaw

    # Wait a moment and check status
    sleep 3
    if systemctl is-active --quiet openclaw; then
        log "OpenClaw gateway is RUNNING"
    else
        warn "OpenClaw gateway may not have started cleanly"
        warn "Check logs: journalctl -u openclaw -n 50"
    fi

    log "Phase 6 complete"
}

# =============================================================================
# PHASE 6b: Mission Control Dashboard (optional)
# =============================================================================
phase6b_mission_control() {
    header "Phase 6b: Mission Control Dashboard"

    local MC_DIR="/home/${CLAW_USER}/mission-control"

    if command -v git &>/dev/null; then
        log "Cloning Mission Control dashboard..."
        if [[ -d "$MC_DIR" ]]; then
            rm -rf "$MC_DIR"
        fi

        # Clone the mission control repo
        su - ${CLAW_USER} -c "git clone https://github.com/openclaw/openclaw-mission-control.git ${MC_DIR}" 2>/dev/null || {
            warn "Could not clone Mission Control repo — may not be publicly available yet"
            warn "You can set it up manually later"
            return 0
        }

        # Configure environment
        cat > "${MC_DIR}/.env.local" << MCEOF
NEXT_PUBLIC_GATEWAY_URL=http://127.0.0.1:4200
NEXT_PUBLIC_AUTH_TOKEN=${GATEWAY_TOKEN}
PORT=3000
MCEOF

        # Install dependencies and build
        su - ${CLAW_USER} -c "cd ${MC_DIR} && npm install && npm run build" 2>/dev/null || {
            warn "Mission Control build failed — you can build it manually later"
            return 0
        }

        # Create systemd service for Mission Control
        cat > /etc/systemd/system/openclaw-mc.service << 'MCSERVICEEOF'
[Unit]
Description=OpenClaw Mission Control Dashboard
After=openclaw.service
Wants=openclaw.service

[Service]
Type=simple
User=clawuser
Group=clawuser
WorkingDirectory=/home/clawuser/mission-control
ExecStart=/usr/bin/npm start
Restart=on-failure
RestartSec=5
Environment=NODE_ENV=production
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
MCSERVICEEOF

        systemctl daemon-reload
        systemctl enable openclaw-mc
        systemctl start openclaw-mc
        log "Mission Control dashboard running on port 3000"
        log "Access via: ssh -L 3000:localhost:3000 root@137.184.15.207"
    fi

    log "Phase 6b complete"
}

# =============================================================================
# Verification
# =============================================================================
verify() {
    header "Verification Checklist"

    local PASS=0
    local FAIL=0

    # Check swap
    if free -h | grep -q 'Swap:.*[1-9]'; then
        log "✓ Swap is active: $(free -h | grep Swap | awk '{print $2}')"
        ((PASS++))
    else
        error "✗ Swap not active"
        ((FAIL++))
    fi

    # Check firewall
    if ufw status | grep -q 'active'; then
        log "✓ Firewall is active"
        ((PASS++))
    else
        error "✗ Firewall not active"
        ((FAIL++))
    fi

    # Check Node.js
    if command -v node &>/dev/null; then
        log "✓ Node.js $(node --version) installed"
        ((PASS++))
    else
        error "✗ Node.js not found"
        ((FAIL++))
    fi

    # Check OpenClaw
    if command -v openclaw &>/dev/null; then
        log "✓ OpenClaw installed"
        ((PASS++))
    else
        error "✗ OpenClaw not found"
        ((FAIL++))
    fi

    # Check config file
    if [[ -f "${OPENCLAW_DIR}/openclaw.json" ]]; then
        log "✓ Configuration file exists"
        ((PASS++))
    else
        error "✗ Configuration file missing"
        ((FAIL++))
    fi

    # Check all agent workspaces
    for agent in henry coder scout writer watcher; do
        if [[ -f "${OPENCLAW_DIR}/workspace-${agent}/SOUL.md" ]]; then
            log "✓ Agent ${agent} workspace configured"
            ((PASS++))
        else
            error "✗ Agent ${agent} workspace missing SOUL.md"
            ((FAIL++))
        fi
    done

    # Check systemd service
    if systemctl is-active --quiet openclaw 2>/dev/null; then
        log "✓ OpenClaw service is running"
        ((PASS++))
    else
        warn "⚠ OpenClaw service not running (may need: systemctl start openclaw)"
        ((FAIL++))
    fi

    # Check file permissions
    local CONFIG_PERMS=$(stat -c %a "${OPENCLAW_DIR}/openclaw.json" 2>/dev/null || echo "000")
    if [[ "$CONFIG_PERMS" == "600" ]]; then
        log "✓ Config file permissions correct (600)"
        ((PASS++))
    else
        warn "⚠ Config file permissions: ${CONFIG_PERMS} (expected 600)"
        ((FAIL++))
    fi

    # Summary
    echo ""
    header "Deployment Summary"
    log "Passed: ${PASS}"
    if [[ $FAIL -gt 0 ]]; then
        error "Failed: ${FAIL}"
    else
        log "Failed: 0"
    fi

    echo ""
    log "=== IMPORTANT INFORMATION ==="
    log "Gateway Token: ${GATEWAY_TOKEN:0:8}...${GATEWAY_TOKEN: -8}"
    log "Token saved to: /root/.openclaw-gateway-token"
    log ""
    log "=== NEXT STEPS ==="
    log "1. Test agents:     openclaw agents list --bindings"
    log "2. Check health:    openclaw doctor"
    log "3. View cron jobs:  openclaw cron list"
    log "4. View logs:       journalctl -u openclaw -f"
    log "5. Mission Control: ssh -L 3000:localhost:3000 root@137.184.15.207"
    log "                    then open http://localhost:3000 in your browser"
    log ""
    log "=== TELEGRAM SETUP ==="
    log "If you haven't set up Telegram bots yet:"
    log "1. Message @BotFather on Telegram"
    log "2. Create 5 bots: HenryClawBot, CoderClawBot, ScoutClawBot, WriterClawBot, WatcherClawBot"
    log "3. Copy each bot token into ${OPENCLAW_DIR}/openclaw.json"
    log "4. Restart: systemctl restart openclaw"
    log ""
    log "=== USEFUL COMMANDS ==="
    log "openclaw status                    — Check gateway status"
    log "openclaw agents list --bindings    — List agents and bindings"
    log "openclaw cron list                 — View scheduled jobs"
    log "openclaw memory search \"query\"     — Search agent memories"
    log "openclaw doctor                    — Run diagnostics"
    log "systemctl restart openclaw         — Restart gateway"
    log "journalctl -u openclaw -f          — Tail logs"
}

# =============================================================================
# PHASE 5: Shiny Monitoring Dashboard
# =============================================================================
phase5_dashboard() {
    header "Phase 5: Shiny Monitoring Dashboard"

    local DASH_DIR="/opt/clawinc-dashboard"

    # 5a. Install Python venv support
    apt-get install -y -qq python3-venv python3-pip

    # 5b. Create dashboard directory and venv
    mkdir -p "${DASH_DIR}"
    if [[ ! -d "${DASH_DIR}/venv" ]]; then
        python3 -m venv "${DASH_DIR}/venv"
        log "Python venv created at ${DASH_DIR}/venv"
    else
        log "Python venv already exists"
    fi

    # 5c. Install Python dependencies
    "${DASH_DIR}/venv/bin/pip" install --quiet --upgrade pip
    "${DASH_DIR}/venv/bin/pip" install --quiet shiny psutil
    log "Installed shiny and psutil"

    # 5d. Copy dashboard files from deploy bundle
    if [[ -f "${DEPLOY_DIR}/../dashboard/app.py" ]]; then
        cp "${DEPLOY_DIR}/../dashboard/app.py" "${DASH_DIR}/app.py"
        cp "${DEPLOY_DIR}/../dashboard/requirements.txt" "${DASH_DIR}/requirements.txt"
        log "Dashboard app.py installed"
    elif [[ -f "${DEPLOY_DIR}/dashboard/app.py" ]]; then
        cp "${DEPLOY_DIR}/dashboard/app.py" "${DASH_DIR}/app.py"
        log "Dashboard app.py installed (from deploy/dashboard/)"
    else
        warn "dashboard/app.py not found in bundle — skipping file copy"
        warn "Manually copy dashboard/app.py to ${DASH_DIR}/app.py before starting"
    fi

    # 5e. Install and enable systemd service
    if [[ -f "${DEPLOY_DIR}/clawinc-dashboard.service" ]]; then
        cp "${DEPLOY_DIR}/clawinc-dashboard.service" /etc/systemd/system/clawinc-dashboard.service
    else
        cat > /etc/systemd/system/clawinc-dashboard.service << 'DASHEOF'
[Unit]
Description=ClawInc Dashboard (Shiny for Python)
After=network.target openclaw.service
Wants=openclaw.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/clawinc-dashboard
ExecStart=/opt/clawinc-dashboard/venv/bin/shiny run app.py --host 0.0.0.0 --port 8050
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
DASHEOF
    fi

    systemctl daemon-reload
    systemctl enable clawinc-dashboard

    if [[ -f "${DASH_DIR}/app.py" ]]; then
        systemctl start clawinc-dashboard
        sleep 3
        if systemctl is-active --quiet clawinc-dashboard; then
            log "Dashboard is RUNNING at http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_IP'):8050"
        else
            warn "Dashboard service not running — check: journalctl -u clawinc-dashboard -n 20"
        fi
    else
        warn "Skipping dashboard start — app.py not present. Copy it and run: systemctl start clawinc-dashboard"
    fi

    log "Phase 5 complete"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
main() {
    echo "" > "$LOG_FILE"

    header "ClawInc — OpenClaw Multi-Agent Deployment v0.90"
    echo "Server: $(hostname) ($(curl -s ifconfig.me 2>/dev/null || echo 'unknown'))"
    echo "Date:   $(date)"
    echo "OS:     $(lsb_release -ds 2>/dev/null || cat /etc/os-release | head -1)"
    echo ""

    preflight
    phase1_server_prep
    phase2_install
    phase3_configure
    phase7_security
    phase6_systemd
    phase5_dashboard
    phase6b_mission_control
    verify

    header "Deployment Complete!"
    log "Full log saved to: ${LOG_FILE}"
}

# Run it
main "$@"

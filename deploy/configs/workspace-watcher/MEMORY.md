# MEMORY — Initial State

## ClawInc Operations Division

**Status**: Initialized and operational
**Role**: System Monitor / Overnight Worker
**Division**: Operations & Infrastructure

## Server Configuration

**Platform**: DigitalOcean Droplet
**Operating System**: Ubuntu 24.04 LTS
**Hostname**: ClawInc
**IP Address**: 137.184.15.207

**Hardware Specifications**:
- CPU: 1 vCPU
- RAM: 1GB
- Swap: 2GB
- Disk: 24GB total storage
- Network: DigitalOcean private networking enabled

**Deployment Context**: Marketing analytics course project

## Monitoring Configuration

**Heartbeat Cadence**: Every 30 minutes (48 checks per day)
**Weekly Maintenance**: Sunday 4:00 AM (session cleanup)
**Daily Reports**: 6:00 AM (24-hour summary)

## Alert Thresholds

**Memory**:
- WARNING: RAM usage > 80%
- CRITICAL: RAM usage > 95%
- WARNING: Swap usage > 70%
- CRITICAL: Swap usage > 90%

**Disk Space**:
- WARNING: Usage > 85%
- CRITICAL: Usage > 95%

**CPU Load**:
- WARNING: 5-minute average > 2.0
- CRITICAL: 5-minute average > 3.0 (sustained)

**Agent Health**:
- WARNING: Any agent unresponsive for > 5 minutes
- CRITICAL: Any agent unresponsive for > 15 minutes
- CRITICAL: Multiple agents (2+) unresponsive

## Reporting Structure

**Direct Report**: Henry (orchestrator agent)
**Escalation Path**: Henry → Human operators
**Communication Method**: Agent-to-agent messaging

## ClawInc Agent Roster

1. **Henry** - Orchestrator
2. **Watcher** - System Monitor (this agent)
3. **Builder** - Development & Deployment
4. **Analyst** - Data Analysis
5. **Researcher** - Information Gathering

## Monitored Services

- OpenClaw Gateway (main process)
- Agent runtime processes (5 agents)
- System services (sshd, systemd, journald)
- Network connectivity

## Storage Locations

**Logs**: `/var/log/openclaw/`
**Session Data**: `/var/lib/openclaw/sessions/`
**Temporary Files**: `/tmp/openclaw/`
**Config Files**: `/etc/openclaw/`

## Baseline Metrics (Initial)

**Recorded at initialization**:
- RAM usage: ~400MB (40% utilized)
- Swap usage: 0MB (0% utilized)
- Disk usage: 8.2GB / 24GB (34% utilized)
- CPU load: 0.15, 0.12, 0.10 (1m, 5m, 15m)
- Uptime: Will be tracked from first heartbeat

## Historical Context

**First deployment**: Part of BOT-ARMY-518 project
**Project goal**: Multi-agent system for marketing analytics automation
**Operational mode**: 24/7 monitoring with minimal human intervention

## Known Constraints

- Limited RAM (1GB) requires careful memory management
- Single vCPU means CPU-intensive tasks must be scheduled carefully
- All agents share resources — monitor for resource contention
- Network-dependent operations may experience DigitalOcean datacenter latency

## Maintenance Windows

**Preferred**: Sunday 3:00 AM - 5:00 AM (low traffic period)
**Backup window**: Wednesday 2:00 AM - 3:00 AM
**Emergency**: Anytime, with immediate notification to Henry

## Success Metrics

- Uptime > 99.5%
- Alert response time < 2 minutes
- False positive rate < 5%
- Successful weekly cleanups: 100%
- Resource utilization within thresholds: > 95% of checks

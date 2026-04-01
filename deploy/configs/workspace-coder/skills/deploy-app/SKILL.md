# SKILL: deploy-app

## Description

Deploy applications to production on the server. This skill covers reviewing code for production readiness, setting up dependencies, configuring the environment, deploying with systemd or PM2, verifying the deployment, and reporting status to Henry.

## Purpose

Getting code from development to production reliably and safely. A good deployment means the application runs smoothly, starts automatically, handles errors gracefully, and can be monitored effectively.

## When to Use

- Application is ready for production use
- Henry requests deployment of a completed project
- Need to update an existing deployed application
- Setting up a new service or tool
- Deploying marketing dashboards or analytics tools
- Making internal tools available to the team

## Execution Steps

### 1. Review the App for Production Readiness

**Code quality check:**
- Code is tested and working
- No debug statements or console.logs in production
- Error handling is comprehensive
- No hardcoded sensitive data

**Security review:**
```bash
# Check for secrets in code
grep -r "password\|api_key\|secret" /home/clawuser/projects/app-name/

# Ensure .env or config files are used
# Verify .gitignore excludes sensitive files
```

**Configuration check:**
- Environment-specific settings externalized
- Config files or environment variables used
- Database connections configurable
- API endpoints configurable

**Dependencies:**
- All dependencies listed (requirements.txt, package.json)
- Version pinning for stability
- No development-only dependencies in production

**Documentation:**
- README exists with setup instructions
- Usage documented
- Environment variables documented
- Known issues/limitations noted

**Performance:**
- No obvious performance bottlenecks
- Resource usage reasonable
- Logging appropriate (not too verbose)

**Checklist:**
```
✓ Code tested and working
✓ No hardcoded secrets
✓ Environment variables configured
✓ Dependencies documented
✓ Error handling robust
✓ Logging configured
✓ README complete
✓ Security review passed
```

### 2. Set Up Dependencies

**For Python applications:**

```bash
# Navigate to project
cd /home/clawuser/projects/app-name/

# Create virtual environment
python3 -m venv venv

# Activate environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Verify installation
pip list
```

**For Node.js applications:**

```bash
# Navigate to project
cd /home/clawuser/projects/app-name/

# Install production dependencies only
npm install --production

# Or if using package-lock.json
npm ci --production

# Verify installation
npm list --depth=0
```

**For R applications:**

```bash
# Install required packages
Rscript -e "install.packages(c('package1', 'package2'), repos='https://cran.r-project.org')"

# Or use packrat/renv for reproducibility
```

**System dependencies:**

```bash
# If system packages needed
sudo apt-get update
sudo apt-get install -y package-name

# Verify installation
which package-name
```

**Database setup (if needed):**

```bash
# PostgreSQL
createdb dbname

# MongoDB
mongo
> use dbname

# SQLite (usually just a file)
# Ensure directory has proper permissions
```

### 3. Configure Environment

**Create environment file:**

```bash
# Create .env file
nano /home/clawuser/projects/app-name/.env
```

**Example .env:**
```bash
# Application settings
NODE_ENV=production
PORT=3000
LOG_LEVEL=info

# Database
DATABASE_URL=postgresql://user:pass@localhost/dbname

# API keys (use actual values, never commit this file)
API_KEY=actual_key_here

# Paths
DATA_DIR=/home/clawuser/data/app-name
```

**Set proper permissions:**

```bash
# Secure the .env file
chmod 600 /home/clawuser/projects/app-name/.env

# Ensure app directory has correct ownership
chown -R clawuser:clawuser /home/clawuser/projects/app-name/
```

**Create necessary directories:**

```bash
# Data directory
mkdir -p /home/clawuser/data/app-name

# Log directory
mkdir -p /home/clawuser/logs/app-name

# Set permissions
chmod 755 /home/clawuser/data/app-name
chmod 755 /home/clawuser/logs/app-name
```

**Test configuration:**

```bash
# Test that app can read config
cd /home/clawuser/projects/app-name/
./test-config.sh  # or however you test

# Verify environment variables load correctly
```

### 4. Deploy (systemd service or PM2)

#### Option A: Deploy with systemd (Recommended for Linux)

**Create systemd service file:**

```bash
sudo nano /etc/systemd/system/app-name.service
```

**For Node.js app:**
```ini
[Unit]
Description=App Name - Marketing Analytics Tool
After=network.target

[Service]
Type=simple
User=clawuser
WorkingDirectory=/home/clawuser/projects/app-name
Environment=NODE_ENV=production
ExecStart=/usr/bin/node /home/clawuser/projects/app-name/app.js
Restart=always
RestartSec=10
StandardOutput=append:/home/clawuser/logs/app-name/output.log
StandardError=append:/home/clawuser/logs/app-name/error.log

[Install]
WantedBy=multi-user.target
```

**For Python app:**
```ini
[Unit]
Description=App Name - Python Service
After=network.target

[Service]
Type=simple
User=clawuser
WorkingDirectory=/home/clawuser/projects/app-name
Environment=PYTHONUNBUFFERED=1
ExecStart=/home/clawuser/projects/app-name/venv/bin/python app.py
Restart=always
RestartSec=10
StandardOutput=append:/home/clawuser/logs/app-name/output.log
StandardError=append:/home/clawuser/logs/app-name/error.log

[Install]
WantedBy=multi-user.target
```

**Enable and start service:**

```bash
# Reload systemd to recognize new service
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable app-name

# Start the service
sudo systemctl start app-name

# Check status
sudo systemctl status app-name
```

#### Option B: Deploy with PM2 (Alternative for Node.js)

**Install PM2 globally:**

```bash
npm install -g pm2
```

**Create PM2 ecosystem file:**

```bash
nano /home/clawuser/projects/app-name/ecosystem.config.js
```

```javascript
module.exports = {
  apps: [{
    name: 'app-name',
    script: './app.js',
    cwd: '/home/clawuser/projects/app-name',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/home/clawuser/logs/app-name/error.log',
    out_file: '/home/clawuser/logs/app-name/output.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
  }]
};
```

**Start with PM2:**

```bash
# Start application
pm2 start ecosystem.config.js

# Save PM2 process list
pm2 save

# Setup PM2 to start on boot
pm2 startup

# Check status
pm2 status
pm2 logs app-name
```

#### Option C: Web Applications (nginx reverse proxy)

**If deploying a web app, configure nginx:**

```bash
sudo nano /etc/nginx/sites-available/app-name
```

```nginx
server {
    listen 80;
    server_name app-name.local;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

**Enable site:**

```bash
sudo ln -s /etc/nginx/sites-available/app-name /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 5. Verify It's Running

**Check service status:**

```bash
# For systemd
sudo systemctl status app-name

# For PM2
pm2 status app-name
pm2 logs app-name --lines 50
```

**Check process:**

```bash
# See if process is running
ps aux | grep app-name

# Check port is listening
sudo netstat -tlnp | grep :3000
# or
sudo ss -tlnp | grep :3000
```

**Test functionality:**

```bash
# For web apps
curl http://localhost:3000
curl http://localhost:3000/health

# For API endpoints
curl http://localhost:3000/api/status

# Check response codes
curl -I http://localhost:3000
```

**Check logs:**

```bash
# View recent logs
tail -f /home/clawuser/logs/app-name/output.log
tail -f /home/clawuser/logs/app-name/error.log

# For systemd
journalctl -u app-name -f

# For PM2
pm2 logs app-name
```

**Test core functionality:**

```bash
# Run any smoke tests
cd /home/clawuser/projects/app-name/
./smoke-test.sh

# Or test manually
# Execute main functions and verify outputs
```

**Verify auto-restart:**

```bash
# For systemd - kill process and see if it restarts
sudo systemctl restart app-name
sleep 5
sudo systemctl status app-name

# For PM2
pm2 restart app-name
sleep 5
pm2 status app-name
```

**Performance check:**

```bash
# Monitor resource usage
top -p $(pgrep -f app-name)

# Check memory
ps aux | grep app-name

# Check disk usage
df -h
du -sh /home/clawuser/projects/app-name/
```

### 6. Report Deployment Status to Henry

**Send deployment report:**

```
To: Henry
Subject: [Deployed] App Name - Production Ready

Status: Successfully deployed and verified

Application: app-name
Location: /home/clawuser/projects/app-name/
Deployment type: systemd service | PM2 process | standalone

Service details:
- Service name: app-name
- Port: 3000 (if applicable)
- Auto-restart: Enabled
- Start on boot: Enabled

Verification completed:
✓ Service running and healthy
✓ Process active and responsive
✓ Logs show no errors
✓ Core functionality tested
✓ Auto-restart verified
✓ Resource usage normal

Access:
- URL: http://localhost:3000 (if web app)
- Command: systemctl status app-name
- Logs: /home/clawuser/logs/app-name/

Configuration:
- Environment: Production
- Dependencies: Installed
- Database: Connected (if applicable)
- API keys: Configured

Monitoring:
- Logs: /home/clawuser/logs/app-name/
- Check status: sudo systemctl status app-name
- Restart: sudo systemctl restart app-name

Notes:
- Any special considerations
- Known limitations
- Suggested monitoring

Deployment complete. Application is live and operational.
```

**Document deployment:**

Create or update `/home/clawuser/projects/app-name/DEPLOYMENT.md`:

```markdown
# Deployment Documentation

## Production Setup

**Deployed**: 2026-04-01
**Method**: systemd service
**Status**: Active

## Service Management

Start: `sudo systemctl start app-name`
Stop: `sudo systemctl stop app-name`
Restart: `sudo systemctl restart app-name`
Status: `sudo systemctl status app-name`
Logs: `journalctl -u app-name -f`

## Configuration

Environment variables: `/home/clawuser/projects/app-name/.env`
Service file: `/etc/systemd/system/app-name.service`

## Monitoring

Logs directory: `/home/clawuser/logs/app-name/`
Output log: `output.log`
Error log: `error.log`

## Maintenance

Update procedure:
1. Pull latest code
2. Install dependencies
3. Restart service
4. Verify deployment

## Troubleshooting

If service fails to start:
- Check logs: `journalctl -u app-name -n 50`
- Verify config: Check .env file
- Test manually: Run command directly

## Contact

Maintained by: Coder (ClawInc Software Engineer)
Issues: Report to Henry
```

## Deployment Checklist

Before reporting deployment complete, verify:

```
Pre-deployment:
✓ Code reviewed and tested
✓ Dependencies installed
✓ Configuration set up
✓ Environment variables configured
✓ Secrets secured
✓ Directories created with correct permissions

Deployment:
✓ Service/process created
✓ Auto-restart enabled
✓ Start on boot configured
✓ Logs configured

Verification:
✓ Service is running
✓ Process is healthy
✓ No errors in logs
✓ Functionality tested
✓ Auto-restart works
✓ Resources normal

Documentation:
✓ Deployment documented
✓ Service management commands noted
✓ Monitoring information provided
✓ Henry notified
```

## Common Deployment Issues

**Service won't start:**
- Check syntax in service file
- Verify file paths are correct
- Ensure user has permissions
- Check for port conflicts

**Application crashes:**
- Review error logs
- Check environment variables
- Verify dependencies installed
- Test running manually

**Can't connect:**
- Check firewall rules
- Verify port is listening
- Check nginx config (if used)
- Ensure service is running

**High resource usage:**
- Check for memory leaks
- Review log verbosity
- Monitor over time
- Optimize if needed

## Success Criteria

Deploy-app skill is successful when:
- Application is running in production
- Service auto-restarts on failure
- Starts automatically on system boot
- Logs are captured and accessible
- Core functionality verified
- Deployment documented
- Henry notified with complete info

## Tips for Smooth Deployments

1. **Test first** - Deploy only tested code
2. **Use process managers** - systemd or PM2 for reliability
3. **Enable auto-restart** - Services should recover automatically
4. **Capture logs** - Always know what's happening
5. **Document everything** - Future you will thank you
6. **Verify thoroughly** - Don't assume it works
7. **Monitor after deploy** - Watch for issues

---

**Remember**: A successful deployment means the application runs reliably without intervention. Deploy with confidence, verify thoroughly, and ensure it stays running.

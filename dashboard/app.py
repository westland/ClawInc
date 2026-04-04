"""
ClawInc Dashboard — Shiny for Python
Monitors OpenClaw multi-agent system on DigitalOcean droplet.
Run: shiny run app.py --host 0.0.0.0 --port 8050
"""

from shiny import App, ui, render, reactive
import subprocess
import json
import os
import psutil
import time
from pathlib import Path
from datetime import datetime

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

OPENCLAW_USER    = "clawuser"
OPENCLAW_HOME    = Path(f"/home/{OPENCLAW_USER}/.openclaw")
CONFIG_PATH      = OPENCLAW_HOME / "openclaw.json"
LOG_PATH         = OPENCLAW_HOME / "logs" / "openclaw.log"
DROPLET_IP       = "137.184.15.207"
REFRESH_SECONDS  = 30
CRON_CACHE_TTL   = 300    # re-run 'openclaw cron list' at most once every 5 min

AGENT_ROLES = {
    "henry":   {"role": "Lead Agent",    "icon": "[H]"},
    "coder":   {"role": "Dev Agent",     "icon": "[C]"},
    "scout":   {"role": "Research Bot",  "icon": "[S]"},
    "writer":  {"role": "Content Bot",   "icon": "[W]"},
    "watcher": {"role": "Monitor Bot",   "icon": "[*]"},
}

MODEL_SHORT = {
    "anthropic/claude-opus-4-6":          "Opus 4.6",
    "anthropic/claude-sonnet-4-5-20250929": "Sonnet 4.5",
    "anthropic/claude-haiku-4-5-20251001":  "Haiku 4.5",
}

# ---------------------------------------------------------------------------
# Data helpers
# ---------------------------------------------------------------------------

def load_config():
    try:
        with open(CONFIG_PATH) as f:
            return json.load(f)
    except Exception as e:
        return {"_error": str(e)}


def get_agents(config):
    """Return agent list from config, enriched with role metadata."""
    agents = config.get("agents", {}).get("list", [])
    defaults = config.get("agents", {}).get("defaults", {})
    default_model = defaults.get("model", {}).get("primary", "unknown")
    result = []
    for a in agents:
        model_id = a.get("model", default_model)
        result.append({
            "id":       a.get("id", "?"),
            "name":     a.get("name", "?"),
            "model":    MODEL_SHORT.get(model_id, model_id.split("/")[-1]),
            "thinking": a.get("thinkingDefault", "—"),
            "workspace": a.get("workspace", "—"),
            "icon":     AGENT_ROLES.get(a.get("id", ""), {}).get("icon", "[?]"),
            "role":     AGENT_ROLES.get(a.get("id", ""), {}).get("role", "Agent"),
        })
    return result


def get_bindings(config):
    return config.get("bindings", [])


def get_telegram_accounts(config):
    return list(config.get("channels", {}).get("telegram", {}).get("accounts", {}).keys())


def get_service_status():
    try:
        r = subprocess.run(
            ["systemctl", "is-active", "openclaw"],
            capture_output=True, text=True, timeout=3
        )
        return r.stdout.strip()
    except Exception:
        return "unknown"


def get_process_info():
    """Find the openclaw-gateway process and return uptime + memory."""
    for proc in psutil.process_iter(["pid", "name", "create_time", "memory_info"]):
        try:
            if "openclaw" in proc.info["name"].lower():
                uptime_s = (datetime.now().timestamp() - proc.info["create_time"])
                h, rem = divmod(int(uptime_s), 3600)
                m, s = divmod(rem, 60)
                mem_mb = proc.info["memory_info"].rss / 1024 / 1024
                return {
                    "pid":    proc.info["pid"],
                    "uptime": f"{h}h {m}m {s}s",
                    "mem_mb": round(mem_mb, 1),
                }
        except Exception:
            pass
    return None


def get_system_resources():
    vm = psutil.virtual_memory()
    disk = psutil.disk_usage("/")
    cpu = psutil.cpu_percent(interval=0.3)
    return {
        "cpu_pct":   cpu,
        "ram_used":  round(vm.used / 1024**3, 2),
        "ram_total": round(vm.total / 1024**3, 2),
        "ram_pct":   vm.percent,
        "disk_used": round(disk.used / 1024**3, 1),
        "disk_total":round(disk.total / 1024**3, 1),
        "disk_pct":  disk.percent,
    }


def get_log_tail(n=60):
    if not LOG_PATH.exists():
        return ["(no log file yet — bot activity will appear here once messages are exchanged)"]
    try:
        with open(LOG_PATH) as f:
            lines = f.readlines()
        return [l.rstrip() for l in lines[-n:]]
    except Exception as e:
        return [f"Error reading log: {e}"]


def get_workspace_summary(agent_id):
    ws = OPENCLAW_HOME / f"workspace-{agent_id}"
    if not ws.exists():
        return {"initialized": False, "soul_lines": 0, "memory_files": 0, "skills": 0}
    soul = ws / "SOUL.md"
    memory = ws / "memory"
    skills = ws / "skills"
    return {
        "initialized":  True,
        "soul_lines":   len(soul.read_text().splitlines()) if soul.exists() else 0,
        "memory_files": len(list(memory.glob("*.md"))) if memory.exists() else 0,
        "skills":       len(list(skills.glob("*.md"))) if skills.exists() else 0,
    }


_cron_cache: list = []
_cron_last_fetch: float = 0.0

def get_cron_jobs():
    """Try openclaw cron list; time-cached to avoid subprocess pile-up."""
    global _cron_cache, _cron_last_fetch
    now = time.time()
    if _cron_cache and (now - _cron_last_fetch) < CRON_CACHE_TTL:
        return _cron_cache
    try:
        r = subprocess.run(
            ["sudo", "-u", OPENCLAW_USER, "openclaw", "cron", "list"],
            capture_output=True, text=True, timeout=5
        )
        lines = r.stdout.strip().splitlines()
        if lines and "error" not in lines[0].lower():
            _cron_cache = lines
            _cron_last_fetch = now
            return lines
    except Exception:
        pass
    _cron_cache = ["(cron list unavailable — run 'openclaw cron list' manually on the server)"]
    _cron_last_fetch = now
    return _cron_cache


# ---------------------------------------------------------------------------
# CSS
# ---------------------------------------------------------------------------

CSS = """
body { font-family: 'Courier New', monospace; background: #0f0f14; color: #c9d1d9; }
h1 { color: #58a6ff; border-bottom: 1px solid #30363d; padding-bottom: 8px; }
h2 { color: #79c0ff; margin-top: 24px; }
h3 { color: #8b949e; font-size: 0.85em; text-transform: uppercase; letter-spacing: 2px; }
.card { background: #161b22; border: 1px solid #30363d; border-radius: 6px;
        padding: 14px; margin-bottom: 12px; }
.status-active   { color: #3fb950; font-weight: bold; }
.status-inactive { color: #f85149; font-weight: bold; }
.status-unknown  { color: #d29922; font-weight: bold; }
.agent-card { background: #161b22; border: 1px solid #21262d; border-radius: 6px;
              padding: 12px; height: 100%; }
.agent-icon { font-size: 1.4em; margin-right: 8px; color: #58a6ff; font-family: monospace; }
.agent-name { font-size: 1.1em; color: #e6edf3; font-weight: bold; }
.agent-role { color: #8b949e; font-size: 0.8em; }
.agent-model{ color: #7ee787; font-size: 0.82em; font-family: monospace; }
.agent-meta { color: #8b949e; font-size: 0.78em; margin-top: 4px; }
.ws-badge    { display: inline-block; background: #21262d; border-radius: 3px;
               padding: 1px 5px; font-size: 0.75em; margin-top: 4px; }
.ws-missing  { color: #f85149; }
.ws-ok       { color: #3fb950; }
.metric-label { color: #8b949e; font-size: 0.8em; }
.metric-value { font-size: 1.5em; color: #e6edf3; font-weight: bold; font-family: monospace; }
.bar-outer { background: #21262d; border-radius: 4px; height: 8px; margin-top: 4px; }
.log-box   { background: #0d1117; border: 1px solid #21262d; border-radius: 4px;
             padding: 12px; font-size: 0.78em; font-family: monospace;
             max-height: 380px; overflow-y: auto; white-space: pre-wrap; color: #8b949e; }
.telegram-badge { display: inline-block; background: #1c6fa6; border-radius: 10px;
                  padding: 2px 8px; font-size: 0.78em; margin: 2px; color: #fff; }
.refresh-ts { color: #30363d; font-size: 0.75em; text-align: right; }
"""


# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

def stat_card(label, output_id):
    return ui.div(
        {"class": "card"},
        ui.tags.div({"class": "metric-label"}, label),
        ui.output_ui(output_id),
    )


app_ui = ui.page_fluid(
    ui.tags.head(ui.tags.style(CSS)),

    # ---- Header -----------------------------------------------------------
    ui.h1("ClawInc  //  OpenClaw Dashboard"),
    ui.p(
        f"Droplet: {DROPLET_IP}  ·  OpenClaw 2026.3.31  ·  5 agents  ·  "
        "auto-refreshes every 30s"
    ),
    ui.output_text("last_refresh_ts"),

    # ---- System metrics row -----------------------------------------------
    ui.h2("System"),
    ui.layout_columns(
        stat_card("Gateway Service", "out_service_status"),
        stat_card("CPU",             "out_cpu"),
        stat_card("RAM",             "out_ram"),
        stat_card("Disk",            "out_disk"),
        col_widths=[3, 3, 3, 3],
    ),
    ui.layout_columns(
        ui.div(
            {"class": "card"},
            ui.tags.div({"class": "metric-label"}, "Process Info"),
            ui.output_ui("out_process"),
        ),
        ui.div(
            {"class": "card"},
            ui.tags.div({"class": "metric-label"}, "Telegram Bots Connected"),
            ui.output_ui("out_telegram_bots"),
        ),
        col_widths=[6, 6],
    ),

    # ---- Agent cards -------------------------------------------------------
    ui.h2("Agents"),
    ui.output_ui("out_agent_cards"),

    # ---- Cron jobs ---------------------------------------------------------
    ui.h2("Cron Jobs"),
    ui.div(
        {"class": "card"},
        ui.output_text_verbatim("out_cron"),
    ),

    # ---- Activity log ------------------------------------------------------
    ui.h2("Activity Log"),
    ui.p({"style": "color:#8b949e;font-size:0.82em"},
         f"Tailing: {LOG_PATH}"),
    ui.output_ui("out_log"),

    # ---- Manual refresh button ---------------------------------------------
    ui.br(),
    ui.input_action_button("btn_refresh", "Refresh Now",
                           style="background:#21262d;color:#c9d1d9;border:1px solid #30363d;"
                                 "padding:6px 18px;border-radius:4px;cursor:pointer;"),
    ui.br(), ui.br(),
)


# ---------------------------------------------------------------------------
# Server
# ---------------------------------------------------------------------------

def server(input, output, session):

    # Reactive value that triggers on timer or button press
    trigger = reactive.value(0)

    @reactive.effect
    def _auto_refresh():
        reactive.invalidate_later(REFRESH_SECONDS)
        with reactive.isolate():
            trigger.set(trigger.get() + 1)

    @reactive.effect
    @reactive.event(input.btn_refresh)
    def _manual_refresh():
        trigger.set(trigger.get() + 1)

    # Cached data — recomputed whenever trigger changes
    @reactive.calc
    def data():
        _ = trigger.get()
        config   = load_config()
        agents   = get_agents(config)
        svc      = get_service_status()
        res      = get_system_resources()
        proc     = get_process_info()
        log      = get_log_tail()
        tg_accts = get_telegram_accounts(config)
        bindings = get_bindings(config)
        cron     = get_cron_jobs()
        ws_info  = {a["id"]: get_workspace_summary(a["id"]) for a in agents}
        return dict(
            config=config, agents=agents, svc=svc, res=res, proc=proc,
            log=log, tg_accts=tg_accts, bindings=bindings, cron=cron, ws_info=ws_info,
            ts=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        )

    # ---- Outputs ----------------------------------------------------------

    @output
    @render.text
    def last_refresh_ts():
        return f"Last refresh: {data()['ts']}"

    @output
    @render.ui
    def out_service_status():
        svc = data()["svc"]
        cls = {
            "active":   "status-active",
            "inactive": "status-inactive",
            "failed":   "status-inactive",
        }.get(svc, "status-unknown")
        return ui.tags.div(
            {"class": f"metric-value {cls}"},
            svc.upper()
        )

    @output
    @render.ui
    def out_cpu():
        pct = data()["res"]["cpu_pct"]
        color = "#f85149" if pct > 85 else "#d29922" if pct > 60 else "#3fb950"
        return ui.tags.div(
            ui.tags.div({"class": "metric-value", "style": f"color:{color}"}, f"{pct}%"),
            ui.tags.div({"class": "bar-outer"},
                ui.tags.div({"style": f"background:{color};height:8px;width:{pct}%;border-radius:4px;"})
            ),
        )

    @output
    @render.ui
    def out_ram():
        d = data()["res"]
        pct = d["ram_pct"]
        color = "#f85149" if pct > 85 else "#d29922" if pct > 70 else "#58a6ff"
        return ui.tags.div(
            ui.tags.div({"class": "metric-value", "style": f"color:{color}"},
                        f"{d['ram_used']:.1f} / {d['ram_total']:.1f} GB"),
            ui.tags.div({"class": "bar-outer"},
                ui.tags.div({"style": f"background:{color};height:8px;width:{pct}%;border-radius:4px;"})
            ),
            ui.tags.div({"class": "metric-label"}, f"{pct}% used"),
        )

    @output
    @render.ui
    def out_disk():
        d = data()["res"]
        pct = d["disk_pct"]
        color = "#f85149" if pct > 85 else "#d29922" if pct > 70 else "#8b949e"
        return ui.tags.div(
            ui.tags.div({"class": "metric-value", "style": f"color:{color}"},
                        f"{d['disk_used']:.0f} / {d['disk_total']:.0f} GB"),
            ui.tags.div({"class": "bar-outer"},
                ui.tags.div({"style": f"background:{color};height:8px;width:{pct}%;border-radius:4px;"})
            ),
            ui.tags.div({"class": "metric-label"}, f"{pct}% used"),
        )

    @output
    @render.ui
    def out_process():
        proc = data()["proc"]
        if proc is None:
            return ui.tags.div({"style": "color:#f85149"}, "No openclaw process found")
        return ui.tags.div(
            ui.tags.div({"class": "metric-value"}, f"PID {proc['pid']}"),
            ui.tags.div({"class": "metric-label"}, f"Uptime: {proc['uptime']}"),
            ui.tags.div({"class": "metric-label"}, f"Memory: {proc['mem_mb']} MB"),
        )

    @output
    @render.ui
    def out_telegram_bots():
        d = data()
        accts = d["tg_accts"]
        bindings = d["bindings"]
        # Build accountId → agentId map
        bound = {b["match"]["accountId"]: b["agentId"]
                 for b in bindings if "match" in b and "accountId" in b["match"]}
        items = []
        for acct in accts:
            agent_name = bound.get(acct, "?")
            items.append(
                ui.tags.span({"class": "telegram-badge"}, f"{acct} → {agent_name}")
            )
        if not items:
            return ui.tags.div({"style": "color:#8b949e"}, "No Telegram accounts configured")
        return ui.tags.div(*items)

    @output
    @render.ui
    def out_agent_cards():
        agents  = data()["agents"]
        ws_info = data()["ws_info"]
        cards   = []
        for a in agents:
            ws = ws_info.get(a["id"], {})
            ws_class = "ws-ok" if ws.get("initialized") else "ws-missing"
            ws_text  = (f"soul:{ws.get('soul_lines',0)}L  "
                        f"mem:{ws.get('memory_files',0)}  "
                        f"skills:{ws.get('skills',0)}"
                       ) if ws.get("initialized") else "not initialized"

            card = ui.div(
                {"class": "agent-card"},
                ui.tags.div(
                    ui.tags.span({"class": "agent-icon"}, a["icon"]),
                    ui.tags.span({"class": "agent-name"}, a["name"]),
                ),
                ui.tags.div({"class": "agent-role"}, a["role"]),
                ui.tags.div({"class": "agent-model"}, a["model"]),
                ui.tags.div({"class": "agent-meta"}, f"thinking: {a['thinking']}"),
                ui.tags.div(
                    {"class": f"ws-badge {ws_class}"},
                    ws_text
                ),
            )
            cards.append(card)

        # 3-col grid of 5 cards (3 + 2)
        return ui.layout_columns(*cards, col_widths=[4, 4, 4, 6, 6])

    @output
    @render.text
    def out_cron():
        lines = data()["cron"]
        return "\n".join(lines) if lines else "(no cron jobs configured)"

    @output
    @render.ui
    def out_log():
        lines = data()["log"]
        content = "\n".join(lines)
        return ui.tags.div({"class": "log-box"}, content)


# ---------------------------------------------------------------------------
# App entry point
# ---------------------------------------------------------------------------

app = App(app_ui, server)

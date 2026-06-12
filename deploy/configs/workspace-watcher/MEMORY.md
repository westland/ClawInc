# MEMORY — Watcher's Initial State (DERMA ART MedSpa)

## Server Profile

*   **Hostname**: DermaArt
*   **IP Address**: `174.138.46.163`
*   **Web Server**: Nginx proxying port 80 to FastAPI backend.
*   **Critical Processes**:
    *   `openclaw.service`: OpenClaw Gateway (Node.js API endpoint).
    *   `dermaart-portal.service`: FastAPI web application serving dashboard and database.

## System Metrics Baseline

*   **RAM Capacity**: 4.0 GB total. Warning limit: 3.4 GB.
*   **Disk Capacity**: 80.0 GB total. Warning limit: 68.0 GB.
*   **Swap Capacity**: 4.0 GB total. Warning limit: 2.8 GB.

## Active Tasks

*   `[ ]` Initialize the 5-minute health check schedule.
*   `[ ]` Verify database access and write permissions on `/opt/dermaart-portal/dermaart.db`.
*   `[ ]` Monitor process swap parameters to ensure the OpenClaw gateway does not run out of memory during JIT compiling phases.

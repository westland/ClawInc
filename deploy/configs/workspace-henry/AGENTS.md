# AGENTS — Operating Instructions for Henry

## Sub-Agent Roster (DERMA ART MedSpa)

### Coder
**Specialty**: Software engineering and server administration.
*   **Aesthetic Tech Focus**:
    *   Maintains the VPS server (IP `174.138.46.163` / `157.230.221.89`).
    *   Updates the Nginx configurations, manages SSL certificates, and handles static assets.
    *   Develops and refines the minimalist, responsive MedSpa homepage based on Sumar's checklist (stark white/cream backgrounds, thin borders, grid structures, and brand photos).
*   **When to delegate to Coder**:
    *   Deploying website changes.
    *   Modifying HTML, CSS styles, or layout scripts.
    *   Optimizing image sizes or updating booking calendar links.
    *   Fixing server bottlenecks or Nginx conflicts.

### Scout
**Specialty**: Competitor intelligence and aesthetic trend monitoring.
*   **MedSpa Research Focus**:
    *   Scans competitor websites, pricing models, and promotion directories in the Scottsdale, AZ area.
    *   Tracks developments and FDA approvals in Neuromodulators, Dermal Fillers, and Biostimulators.
    *   Researches patient acquisition channels and pricing/interest shifts for financing networks (Cherry and CareCredit).
*   **When to delegate to Scout**:
    *   Investigating local pricing for Botox, Dysport, Juvederm, Restylane, or Sculptra.
    *   Monitoring Scottsdale clinic launches or Groupon deals.
    *   Gathering academic or patient satisfaction trends for aesthetic procedures.

### Writer
**Specialty**: Content creation and brand copy.
*   **Boutique Copywriting Focus**:
    *   Drafts high-end, uncluttered web page copy (headlines, sub-headlines, direct access blurbs).
    *   Drafts SMS/text templates for virtual photo consultations and post-care follow-up sequences.
    *   Drafts responses to patient reviews (Google, Yelp, Vagaro) matching a tranquil and premium brand tone.
    *   Creates marketing scripts and email campaigns.
*   **When to delegate to Writer**:
    *   Writing website sections or promotional taglines.
    *   Drafting messages, announcements, or email copy.
    *   Formulating scripts for virtual initial analysis responses.
    *   Writing review responses.

### Watcher
**Specialty**: Infrastructure monitor and maintenance scheduler.
*   **Server Health Focus**:
    *   Pings server resources (CPU, memory swap files, disk capacity) on Droplet `174.138.46.163`.
    *   Verifies OpenClaw gateway connection, SQLite database locks, and Python FastAPI portal processes.
    *   Performs regular housekeeping (clearing node processes, archiving large session logs).
*   **When to delegate to Watcher**:
    *   Checking server diagnostics.
    *   Fixing process bottlenecks or memory threshold warnings.
    *   Running cleanup routines or log analysis.

---

## Delegation Protocol

1.  **Decompose Requests**: When Sumar Kasik asks for a multi-step objective, break it down.
    *   *Example*: "Update our website pricing to match the local average."
    *   *Step 1*: Delegate to **Scout** to find Scottsdale pricing averages.
    *   *Step 2*: Delegate to **Writer** to draft the pricing menu text.
    *   *Step 3*: Delegate to **Coder** to implement the styling and update the layout.
2.  **Task Format**: Always include background context, clear inputs, success criteria, and report delivery instructions.
3.  **Publish Synthesis**: Compile sub-agent outcomes and publish the summary report using the `/usr/local/bin/portal-post` pipeline.

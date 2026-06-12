# MEMORY — Henry's Initial State (DERMA ART MedSpa)

## MedSpa Profile

*   **Brand**: DERMA ART MedSpa
*   **Owner/Provider**: Sumar Kasik, RN (Registered Nurse, Elite Aesthetic Specialist)
*   **Location**: 2923 N 67th Pl, Scottsdale, AZ 85251
*   **Phone (Direct Practice Line)**: 480.630.7542
*   **Email**: info@dermaartmedspa.com
*   **Business Model**: High-end, sole-proprietor boutique clinic. Sumar Kasik handles every consultation, treatment, text, and post-care follow-up directly. This bypassing of rotating clinical staff and administrative desks is the practice's key differentiator ("Direct Access Distinction").

## Technical Infrastructure

*   **Server**: DigitalOcean Droplet (`174.138.46.163`), AMD / 2 vCPUs / 4 GB RAM / 80 GB Disk running Ubuntu 24.04.
*   **Agent Runtime**: OpenClaw Gateway on port `18789` (local REST mode, Telegram disabled).
*   **Command Center Web Portal**: Serves the UI at `http://174.138.46.163` on port `80` (reverse proxied via Nginx) under Basic Auth (`sumar` / `#1DermaArt`).
*   **Client Website**: Client-facing medspa website hosted at `http://157.230.221.89` (or local files in `SUMAR NEW` workspace, to be managed and deployed by Coder).

## Brand Guidelines & Checklist

1.  **Hero Section**: Completely uncluttered. Clean, crisp logo with breathing room. Minimalist headline: "Boutique Artistry. Direct Elite Care." One button: "Book a Consultation."
2.  **Direct Access Distinction**: Clear homepage copy explaining that clients bypass a front desk and rotating staff to deal directly with Sumar Kasik.
3.  **Specialized Service Overview**: List focus categories: Neuromodulators, Dermal Fillers, Biostimulators. Link: "View full boutique menu and pricing" (points to Vagaro booking calendar).
4.  **Two-Way Consultation Suite**: Option 1: In-person consultation button. Option 2: Virtual analysis text link ("Text your photos and questions directly to my private practice line at 480.630.7542 for a direct, confidential response").
5.  **Seamless Financing**: Muted text mentioning all major credit cards accepted, alongside clean logos for Cherry and CareCredit.
6.  **Social Proof & Location**: Footer includes Google review slider (2-3 best 5-star reviews), Instagram 3-4 photo grid, Scottsdale address, phone, and Google Map.
7.  **Visuals**: Stark white or tranquil cream backgrounds, fine-lined borders, premium brand photography.

## Active Tasks

*   `[ ]` Deploy the customized ClawInc Agent company on the server `174.138.46.163`.
*   `[ ]` Initialize automated cron jobs (Scout competitor research, Writer daily memo, Watcher system health).
*   `[ ]` Establish Nginx basic authentication on port 80.
*   `[ ]` Support Coder in refining and verifying the WordPress/HTML layout of the MedSpa homepage.

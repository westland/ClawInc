#!/usr/bin/env bash
# Add IPv4 /etc/hosts entries for sites with broken IPv6 routes on DigitalOcean.
# Run once after provisioning. Safe to re-run (idempotent).
set -e

add_entry() {
  local ip="$1" host="$2"
  if ! grep -qF "$host" /etc/hosts; then
    echo "$ip $host" >> /etc/hosts
    echo "Added: $host -> $ip"
  else
    echo "Already present: $host"
  fi
}

add_entry 104.18.3.115    openrouter.ai
add_entry 185.199.108.133 raw.githubusercontent.com
add_entry 149.154.166.110 api.telegram.org

# Persist through cloud-init reboots
TMPL=/etc/cloud/templates/hosts.debian.tmpl
if [ -f "$TMPL" ]; then
  if ! grep -qF "openrouter.ai" "$TMPL"; then
    printf '
104.18.3.115 openrouter.ai
185.199.108.133 raw.githubusercontent.com
149.154.166.110 api.telegram.org
' >> "$TMPL"
    echo "Wrote entries to $TMPL for cloud-init persistence"
  elif ! grep -qF "api.telegram.org" "$TMPL"; then
    echo '149.154.166.110 api.telegram.org' >> "$TMPL"
    echo "Added api.telegram.org to $TMPL"
  fi
fi

resolvectl flush-caches 2>/dev/null || true
echo "Done — DNS cache flushed"
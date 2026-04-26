#!/bin/bash
# Ensures the openclaw package is symlinked inside each plugin-runtime-deps
# node_modules directory so Telegram and other extensions can import it.
# Always exits 0 — plugin-runtime-deps may not exist yet on a fresh install.
for dir in /home/clawuser/.openclaw/plugin-runtime-deps/openclaw-*/node_modules; do
    [ -d "$dir" ] && ln -sfn /usr/lib/node_modules/openclaw "$dir/openclaw" || true
done
exit 0

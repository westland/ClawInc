#!/bin/bash
# Run as ExecStartPre before the OpenClaw gateway starts.
# Ensures the openclaw package is symlinked inside each plugin-runtime-deps
# node_modules directory so Telegram and other extensions can import it.
# Without this, extensions fail to resolve 'openclaw' after npm updates.
for dir in /home/clawuser/.openclaw/plugin-runtime-deps/openclaw-*/node_modules; do
    [ -d "$dir" ] && ln -sfn /usr/lib/node_modules/openclaw "$dir/openclaw"
done

# delegate-task

Delegate a task to another agent in this ClawInc system.

## How to delegate

Use the **sessions_spawn** tool — NOT Telegram. Bots cannot message each other via Telegram.

```
sessions_spawn(
  agentId: "coder",   // or "scout", "writer", "watcher"
  task: "Write a Python program that prints the current time",
  mode: "run"         // "run" = one-shot; "session" = persistent thread
)
```

The spawned agent runs, completes the task, and the result comes back to you automatically.

## Retry on failure

If `sessions_spawn` returns an error, times out, or the child result is empty:

1. Wait **20 seconds** (the gateway may be restarting after a transient crash)
2. Retry `sessions_spawn` with the same task once
3. If it fails a second time, complete the task yourself and tell the user: "I handled this directly — delegation was unavailable"

Do NOT keep retrying in a loop. Two attempts maximum.

## Available agents

| id | Name | Best for |
|----|------|---------|
| coder | Coder | Code writing, debugging, deployment, program output |
| scout | Scout | Web research, news, trends, facts |
| writer | Writer | Memos, reports, long-form content |
| watcher | Watcher | Health checks, log analysis, system status |

## Example

User: "tell coder to write hello world and post to the portal"

1. Call `sessions_spawn(agentId="coder", task="Write a hello-world Python program. Post the code to the Reports & Memos screen on the portal using the PORTAL_REPORTS_URL env var.")`
2. If it fails, wait 20s and try once more
3. Report the result (or fallback) to the user

## When NOT to delegate

- Simple questions you can answer yourself → just answer
- Tasks you already know how to do → just do it
- The user explicitly wants YOUR answer → give it yourself

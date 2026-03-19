# CPU Monitor

A lightweight macOS launchd agent that monitors Node.js processes and sends a native notification when combined CPU usage exceeds a threshold.

## How it works

- Runs every **5 minutes** via launchd
- Sums CPU usage across all `node` processes
- Sends a macOS notification (with sound) if total CPU exceeds **150%**
- Respects a **10-minute cooldown** between alerts
- Handles Danish locale decimal commas

## Install

```bash
bash install.sh
```

This will:

1. Copy the monitor script to `~/Scripts/`
2. Install and load a launchd agent (`com.lajlev.node-cpu-monitor`)

## Configuration

Edit `~/Scripts/node-cpu-monitor.sh` to adjust:

| Variable | Default | Description |
|---|---|---|
| `CPU_THRESHOLD` | `150` | Combined CPU % to trigger an alert |
| `COOLDOWN_SECONDS` | `600` | Minimum seconds between alerts |

## Logs

- stdout: `/tmp/node-cpu-monitor.log`
- stderr: `/tmp/node-cpu-monitor.err`

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.lajlev.node-cpu-monitor.plist
rm ~/Library/LaunchAgents/com.lajlev.node-cpu-monitor.plist ~/Scripts/node-cpu-monitor.sh
```

#!/bin/bash
# node-cpu-monitor.sh
# Monitors node processes and sends a macOS notification if total CPU exceeds threshold.
# Designed to run via launchd on an interval.

CPU_THRESHOLD=150  # Total combined CPU % across all node processes
COOLDOWN_FILE="/tmp/node-cpu-monitor-last-alert"
COOLDOWN_SECONDS=600  # Don't alert more than once every 10 minutes

# --- Check cooldown ---
if [[ -f "$COOLDOWN_FILE" ]]; then
    last_alert=$(cat "$COOLDOWN_FILE")
    now=$(date +%s)
    elapsed=$(( now - last_alert ))
    if (( elapsed < COOLDOWN_SECONDS )); then
        exit 0
    fi
fi

# --- Gather node CPU usage ---
# ps outputs CPU with comma decimal on Danish locale, so normalize to dot
node_info=$(ps -eo pid,%cpu,command | grep '[n]ode' | grep -v grep)

if [[ -z "$node_info" ]]; then
    exit 0
fi

total_cpu=0
top_processes=""
count=0

while IFS= read -r line; do
    pid=$(echo "$line" | awk '{print $1}')
    cpu=$(echo "$line" | awk '{print $2}' | tr ',' '.')
    cmd=$(echo "$line" | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print ""}' | head -c 80)

    # Add to total (integer comparison, so multiply by 10 for one decimal)
    cpu_int=$(echo "$cpu" | awk '{printf "%d", $1}')
    total_cpu=$(( total_cpu + cpu_int ))

    if (( cpu_int > 50 )); then
        count=$(( count + 1 ))
        top_processes="${top_processes}• PID ${pid}: ${cpu}% — ${cmd}\n"
    fi
done <<< "$node_info"

# --- Alert if over threshold ---
if (( total_cpu > CPU_THRESHOLD )); then
    title="⚠️ Node.js CPU Alert: ${total_cpu}%"
    if (( count == 1 )); then
        message="1 node process is using heavy CPU."
    else
        message="${count} node processes using heavy CPU."
    fi
    # Append top offenders (trimmed for notification)
    detail=$(echo -e "$top_processes" | head -5)
    message="${message}\n${detail}"

    osascript -e "display notification \"$(echo -e "$message")\" with title \"$title\" sound name \"Sosumi\""

    # Update cooldown
    date +%s > "$COOLDOWN_FILE"
fi

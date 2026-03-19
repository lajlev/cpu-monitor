#!/bin/bash
# install.sh — Sets up the node CPU monitor as a launchd agent
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST_SCRIPT="$HOME/Scripts/node-cpu-monitor.sh"
PLIST_NAME="com.lajlev.node-cpu-monitor.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_NAME"

echo "📦 Installing Node.js CPU Monitor..."

# 1. Create ~/Scripts if needed
mkdir -p "$HOME/Scripts"

# 2. Copy script
cp "$SCRIPT_DIR/node-cpu-monitor.sh" "$DEST_SCRIPT"
chmod +x "$DEST_SCRIPT"
echo "✅ Script installed to $DEST_SCRIPT"

# 3. Unload existing agent if present
if launchctl list | grep -q "com.lajlev.node-cpu-monitor"; then
    launchctl unload "$PLIST_DEST" 2>/dev/null || true
    echo "♻️  Unloaded existing agent"
fi

# 4. Copy and load plist
cp "$SCRIPT_DIR/$PLIST_NAME" "$PLIST_DEST"
launchctl load "$PLIST_DEST"
echo "✅ Launch agent loaded"

echo ""
echo "🎉 Done! The monitor will:"
echo "   • Check every 5 minutes"
echo "   • Alert when node processes exceed 150% total CPU"
echo "   • Respect a 10-minute cooldown between alerts"
echo ""
echo "To adjust thresholds, edit: $DEST_SCRIPT"
echo "To uninstall: launchctl unload $PLIST_DEST && rm $PLIST_DEST $DEST_SCRIPT"

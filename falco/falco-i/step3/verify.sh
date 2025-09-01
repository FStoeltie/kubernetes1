#!/bin/bash

# Verify that security activities were detected
echo "Checking for recent Falco security alerts..."

# Get recent Falco logs from the last 10 minutes
RECENT_LOGS=$(sudo journalctl -u falco --since="10 minutes ago" 2>/dev/null | grep -E "(WARNING|ERROR|CRITICAL|ALERT)")

if [ -z "$RECENT_LOGS" ]; then
    echo "❌ Could not retrieve recent Falco logs or no alerts found"
    echo "Let's check if Falco is generating any logs:"
    sudo journalctl -u falco --since="5 minutes ago" | tail -5
    exit 1
fi

# Check for common security alerts that should have been triggered
ALERTS_FOUND=0

# Check for sensitive file access
if echo "$RECENT_LOGS" | grep -q -i "sensitive file\|passwd\|shadow"; then
    echo "✅ Detected sensitive file access alerts"
    ALERTS_FOUND=$((ALERTS_FOUND + 1))
fi

# Check for file system activity
if echo "$RECENT_LOGS" | grep -q -i "opened for reading\|file access\|filesystem"; then
    echo "✅ Detected file system activity alerts"
    ALERTS_FOUND=$((ALERTS_FOUND + 1))
fi

# Check for process/system activity
if echo "$RECENT_LOGS" | grep -q -i "process\|command\|exec"; then
    echo "✅ Detected process execution alerts"
    ALERTS_FOUND=$((ALERTS_FOUND + 1))
fi

# Verify Falco service is still running
if ! systemctl is-active --quiet falco; then
    echo "❌ Falco service is not running"
    exit 1
fi

if [ "$ALERTS_FOUND" -gt 0 ]; then
    echo "✅ Successfully generated and detected $ALERTS_FOUND type(s) of security alerts!"
    echo "✅ Falco is working properly and monitoring your system"
    echo ""
    echo "Recent alerts summary:"
    echo "$RECENT_LOGS" | head -5
else
    echo "⚠️  No security alerts detected. Try running the suspicious commands from the step again."
    echo "Recent Falco logs:"
    sudo journalctl -u falco --since="5 minutes ago" | tail -10
    exit 1
fi

exit 0

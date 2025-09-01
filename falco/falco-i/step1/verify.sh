#!/bin/bash

# Verify Falco is installed and running
echo "Checking if Falco is installed and running..."

# Check if Falco binary exists
if ! command -v falco &> /dev/null; then
    echo "❌ Falco binary not found"
    exit 1
fi

# Check if Falco service is running
if ! systemctl is-active --quiet falco; then
    echo "❌ Falco service is not running"
    echo "Service status:"
    sudo systemctl status falco --no-pager
    exit 1
fi

# Check if Falco service is enabled
if ! systemctl is-enabled --quiet falco; then
    echo "⚠️  Falco service is running but not enabled for startup"
else
    echo "✅ Falco service is enabled and running"
fi

# Test if Falco can load rules
if falco --validate /etc/falco/falco_rules.yaml &> /dev/null; then
    echo "✅ Falco rules validation successful"
else
    echo "❌ Falco rules validation failed"
    exit 1
fi

echo "✅ Falco is installed and running successfully!"
echo "✅ Falco version: $(falco --version)"

exit 0

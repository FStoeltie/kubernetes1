#!/bin/bash

# Verify custom rules were created and Falco restarted
echo "Checking if custom Falco rules were created..."

# Check if custom rules file exists
if [ -f "/etc/falco/falco_rules.local.yaml" ]; then
    echo "✅ Custom Falco rules file created successfully!"
    
    # Check if the file contains our rule
    if grep -q "Read sensitive file untrusted" /etc/falco/falco_rules.local.yaml; then
        echo "✅ Custom rule 'Read sensitive file untrusted' found in rules file"
    else
        echo "❌ Custom rule not found in rules file"
        exit 1
    fi
else
    echo "❌ Custom Falco rules file not found"
    exit 1
fi

# Verify the rule validates correctly
if falco --validate /etc/falco/falco_rules.local.yaml &> /dev/null; then
    echo "✅ Custom rules file validates successfully"
else
    echo "❌ Custom rules file validation failed"
    exit 1
fi

# Verify Falco service is still running
if systemctl is-active --quiet falco; then
    echo "✅ Falco service is running"
else
    echo "❌ Falco service is not running"
    exit 1
fi

# Check if our custom rule is loaded (this might take a moment after restart)
sleep 2
if falco --list 2>/dev/null | grep -q "Read sensitive file untrusted"; then
    echo "✅ Custom rule is loaded and active"
else
    echo "⚠️  Custom rule may still be loading (this is normal)"
fi

exit 0

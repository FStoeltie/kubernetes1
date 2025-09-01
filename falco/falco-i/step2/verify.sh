#!/bin/bash

# Verify that the user correctly identified the Falco rule loading order
echo "Checking if you correctly identified the Falco rule loading order..."

# Check if the answer file exists
if [ ! -f "/tmp/rule-order.txt" ]; then
    echo "❌ Answer file /tmp/rule-order.txt not found"
    echo "Please create the file with the rule loading order"
    exit 1
fi

# Read the user's answer
USER_ANSWER=$(cat /tmp/rule-order.txt)

# Dynamically extract the expected order from falco.yaml
# Look for the rules_file section and extract just the filenames in order
EXPECTED_ORDER=$(awk '
/^rules_file:/ { in_rules=1; next }
in_rules && /^[[:space:]]*-[[:space:]]*\// { 
    gsub(/.*\//, ""); 
    gsub(/^[[:space:]]*-[[:space:]]*/, ""); 
    print 
}
in_rules && /^[^[:space:]]/ && !/^[[:space:]]*-/ { in_rules=0 }
' /etc/falco/falco.yaml)

if [ -z "$EXPECTED_ORDER" ]; then
    echo "❌ Could not extract rule file order from /etc/falco/falco.yaml"
    echo "Please check if Falco is properly installed"
    exit 1
fi

# Clean up whitespace and compare
USER_CLEAN=$(echo "$USER_ANSWER" | tr -d ' \t' | grep -v '^$')
EXPECTED_CLEAN=$(echo "$EXPECTED_ORDER" | tr -d ' \t' | grep -v '^$')

if [ "$USER_CLEAN" = "$EXPECTED_CLEAN" ]; then
    echo "✅ Correct! You identified the proper Falco rule loading order:"
    
    # Display the actual order from the config
    echo "$EXPECTED_ORDER" | nl -b a -s ". "
    echo ""
    echo "✅ This order allows local rules to override default rules"
    echo "✅ and maintains proper rule precedence"
else
    echo "❌ The rule loading order is not correct"
    echo ""
    echo "Your answer:"
    cat /tmp/rule-order.txt
    echo ""
    echo "Expected order (from /etc/falco/falco.yaml):"
    echo "$EXPECTED_ORDER" | nl -b a -s ". "
    echo ""
    echo "Hint: Check the 'rules_file' section in /etc/falco/falco.yaml"
    echo "or run: sudo falco --dry-run 2>&1 | grep -i loading"
    exit 1
fi

# Verify Falco is still running
if systemctl is-active --quiet falco; then
    echo "✅ Falco service is running"
else
    echo "⚠️  Falco service is not running (this is expected for this step)"
fi

exit 0

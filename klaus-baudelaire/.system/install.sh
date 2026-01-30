#!/bin/bash
# Klaus System Installation Script
# Configures UserPromptSubmit hook in settings.json
# (Required until Claude Code fixes plugin hook bug #10225)

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Klaus System - Hook Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Detect plugin installation path
if [ -n "$CLAUDE_PLUGIN_ROOT" ]; then
    KLAUS_ROOT="$CLAUDE_PLUGIN_ROOT"
else
    KLAUS_ROOT="$HOME/.claude"
fi

KLAUS_HOOK="$KLAUS_ROOT/hooks/klaus-delegation.sh"

# Verify hook file exists
if [ ! -f "$KLAUS_HOOK" ]; then
    echo "[!!!] ERROR: Klaus delegation hook not found at:"
    echo "      $KLAUS_HOOK"
    echo ""
    echo "Please ensure Klaus is installed correctly."
    exit 1
fi

echo "[*] Klaus hook found: $KLAUS_HOOK"
echo ""

# Prompt for settings.json scope
echo "Where should Klaus hook be configured?"
echo ""
echo "  1) User settings     (~/.claude/settings.json)"
echo "     Available across all projects"
echo ""
echo "  2) Project settings  (.claude/settings.json)"
echo "     Only for current project, shared via git"
echo ""
echo "  3) Local settings    (.claude/settings.local.json)"
echo "     Only for current project, gitignored"
echo ""
read -p "Select scope [1-3]: " SCOPE_CHOICE

case $SCOPE_CHOICE in
    1)
        SETTINGS_FILE="$HOME/.claude/settings.json"
        SCOPE="user"
        ;;
    2)
        SETTINGS_FILE=".claude/settings.json"
        SCOPE="project"
        ;;
    3)
        SETTINGS_FILE=".claude/settings.local.json"
        SCOPE="local"
        ;;
    *)
        echo "[!!!] Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "[*] Selected: $SCOPE settings"
echo "[*] File: $SETTINGS_FILE"
echo ""

# Create settings file if it doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "[*] Creating new settings file..."
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    echo '{}' > "$SETTINGS_FILE"
fi

# Check if hook already configured
if grep -q "klaus-delegation.sh" "$SETTINGS_FILE" 2>/dev/null; then
    echo "[**] Klaus hook already configured in $SETTINGS_FILE"
    echo ""
    read -p "Reconfigure anyway? [y/N]: " RECONFIGURE
    if [[ ! "$RECONFIGURE" =~ ^[Yy]$ ]]; then
        echo "[*] Skipping hook configuration"
        exit 0
    fi
fi

# Backup settings file
cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup.$(date +%s)"
echo "[*] Backup created: ${SETTINGS_FILE}.backup.*"

# Add hook using jq (if available) or Python
if command -v jq &> /dev/null; then
    # Use jq to add hook
    TEMP_FILE=$(mktemp)
    jq --arg hook_cmd "bash $KLAUS_HOOK" '
        .hooks.UserPromptSubmit = [
            {
                "matcher": "",
                "hooks": [
                    {
                        "type": "command",
                        "command": $hook_cmd
                    }
                ]
            }
        ]
    ' "$SETTINGS_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$SETTINGS_FILE"
    echo "[**] Hook configured using jq"
else
    # Use Python as fallback
    python3 << EOF
import json
import sys

with open('$SETTINGS_FILE', 'r') as f:
    settings = json.load(f)

if 'hooks' not in settings:
    settings['hooks'] = {}

settings['hooks']['UserPromptSubmit'] = [
    {
        'matcher': '',
        'hooks': [
            {
                'type': 'command',
                'command': 'bash $KLAUS_HOOK'
            }
        ]
    }
]

with open('$SETTINGS_FILE', 'w') as f:
    json.dump(settings, f, indent=2)

print('[**] Hook configured using Python')
EOF
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "[***] Klaus delegation hook configured in $SCOPE settings"
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code to load the hook"
echo "  2. Test with: $KLAUS_ROOT/test-klaus-delegation.sh"
echo "  3. Use /fillmemory to initialize project memory"
echo ""
echo "Note: This manual hook configuration is required until"
echo "      Claude Code fixes plugin hook bug #10225"
echo ""

#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║        Claude Code Docker - Uninstaller                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

detect_shell() {
    if [ -n "$BASH_VERSION" ]; then
        echo "bash"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    else
        case "$SHELL" in
            */bash) echo "bash" ;;
            */zsh) echo "zsh" ;;
            *) echo "unknown" ;;
        esac
    fi
}

DETECTED_SHELL=$(detect_shell)

if [ "$DETECTED_SHELL" = "zsh" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    SHELL_CONFIG="$HOME/.bashrc"
fi

echo "This will remove Claude Code Docker from your system."
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled"
    exit 0
fi

echo "🧹 Step 1: Removing shell function..."

if grep -q "claudedev()" "$SHELL_CONFIG" 2>/dev/null; then
    cp "$SHELL_CONFIG" "$SHELL_CONFIG.backup-uninstall-$(date +%Y%m%d-%H%M%S)"
    echo -e "   ${GREEN}✅ Backup created${NC}"
    
    sed '/^# .*Claude Code in Docker/,/^fi$/d' "$SHELL_CONFIG" > "$SHELL_CONFIG.tmp"
    mv "$SHELL_CONFIG.tmp" "$SHELL_CONFIG"
    echo -e "   ${GREEN}✅ Function removed${NC}"
else
    echo -e "   ${YELLOW}ℹ️  Function not found${NC}"
fi

echo ""
echo "🧹 Step 2: Docker resources..."
echo ""
echo "Remove Docker resources?"
echo "  • claude-code image"
echo "  • claude-auth volume"
echo "  • ~/claude-docker directory"
echo ""
read -p "Remove? (y/N) " -n 1 -r
echo
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker volume rm claude-auth 2>/dev/null && echo -e "   ${GREEN}✅ Volume removed${NC}" || echo -e "   ${YELLOW}ℹ️  No volume${NC}"
    docker rmi claude-code 2>/dev/null && echo -e "   ${GREEN}✅ Image removed${NC}" || echo -e "   ${YELLOW}ℹ️  No image${NC}"
    [ -d "$HOME/claude-docker" ] && rm -rf "$HOME/claude-docker" && echo -e "   ${GREEN}✅ Directory removed${NC}"
else
    echo "   Skipped"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              Uninstallation Complete                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Reload shell: source $SHELL_CONFIG"
echo ""

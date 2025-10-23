#!/usr/bin/env bash
set -e

REPO_URL="https://raw.githubusercontent.com/kaspigoz/claude-code-docker/main"
FUNCTION_URL="$REPO_URL/claudedev.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Claude Code Docker - Automated Installer              ║"
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

if [ "$DETECTED_SHELL" = "unknown" ]; then
    echo -e "${RED}❌ Unsupported shell${NC}"
    exit 1
fi

if [ "$DETECTED_SHELL" = "zsh" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    SHELL_CONFIG="$HOME/.bashrc"
fi

echo -e "${BLUE}Detected shell:${NC} $DETECTED_SHELL"
echo -e "${BLUE}Config file:${NC} $SHELL_CONFIG"
echo ""

echo "Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found${NC}"
    echo ""
    echo "Please install Docker first:"
    echo "  • macOS: brew install --cask docker"
    echo "  • Linux: sudo apt-get install docker.io"
    echo "  • Windows: https://docker.com/products/docker-desktop"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker daemon not running${NC}"
    echo ""
    echo "Please start Docker and press Enter..."
    read -r
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker still not running${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Docker found and running${NC}"
echo ""

if grep -q "claudedev()" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  claudedev function already exists${NC}"
    echo ""
    read -p "Reinstall/update? (y/N) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi
    
    echo ""
    echo "Backing up..."
    cp "$SHELL_CONFIG" "$SHELL_CONFIG.backup-$(date +%Y%m%d-%H%M%S)"
    echo -e "${GREEN}✅ Backup created${NC}"
    
    sed '/^# .*Claude Code in Docker/,/^fi$/d' "$SHELL_CONFIG" > "$SHELL_CONFIG.tmp"
    mv "$SHELL_CONFIG.tmp" "$SHELL_CONFIG"
    echo -e "${GREEN}✅ Old function removed${NC}"
    echo ""
fi

echo "Downloading claudedev function..."

if ! curl -fsSL "$FUNCTION_URL" >> "$SHELL_CONFIG"; then
    echo -e "${RED}❌ Failed to download function${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Function installed${NC}"
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                 Installation Complete!                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo ""
echo "1. Reload shell:"
echo -e "   ${BLUE}source $SHELL_CONFIG${NC}"
echo ""
echo "2. Navigate to any project:"
echo -e "   ${BLUE}cd /path/to/your/project${NC}"
echo ""
echo "3. Run Claude Code:"
echo -e "   ${BLUE}claudedev${NC}"
echo ""
echo "For help: ${BLUE}claudedev --help${NC}"
echo ""

read -p "Reload shell configuration now? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    if [ "$DETECTED_SHELL" = "zsh" ]; then
        zsh -c "source $SHELL_CONFIG && type claudedev"
    else
        bash -c "source $SHELL_CONFIG && type claudedev"
    fi
    echo ""
    echo -e "${GREEN}✅ Ready to use!${NC}"
else
    echo ""
    echo "Remember to run: source $SHELL_CONFIG"
fi

echo ""
echo "Happy coding! 🚀"
echo ""

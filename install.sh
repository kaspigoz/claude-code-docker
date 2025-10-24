cat > install.sh << 'ENDINSTALL'
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

# Improved shell detection - prioritize user's default shell
detect_shell() {
    # Check user's default shell first (most reliable)
    case "$SHELL" in
        */zsh)
            echo "zsh"
            return
            ;;
        */bash)
            echo "bash"
            return
            ;;
    esac
    
    # Fallback: check what's running the script
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

DETECTED_SHELL=$(detect_shell)

if [ "$DETECTED_SHELL" = "unknown" ]; then
    echo -e "${RED}❌ Unsupported shell${NC}"
    echo "This installer supports bash and zsh only."
    echo ""
    echo "Your current shell: $SHELL"
    echo ""
    echo "For manual installation, visit:"
    echo "https://github.com/kaspigoz/claude-code-docker"
    exit 1
fi

# Auto-select correct config file based on user's default shell
if [ "$DETECTED_SHELL" = "zsh" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    SHELL_CONFIG="$HOME/.bashrc"
fi

# Create config file if it doesn't exist
if [ ! -f "$SHELL_CONFIG" ]; then
    echo -e "${YELLOW}⚠️  $SHELL_CONFIG doesn't exist, creating it...${NC}"
    touch "$SHELL_CONFIG"
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
    echo ""
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker daemon not running${NC}"
    echo ""
    echo "Please start Docker:"
    echo "  • macOS/Windows: Launch Docker Desktop"
    echo "  • Linux: sudo systemctl start docker"
    echo ""
    read -p "Press Enter when Docker is running, or Ctrl+C to cancel..."
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker still not running${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Docker found and running${NC}"
echo ""

if grep -q "claudedev()" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  claudedev function already exists in $SHELL_CONFIG${NC}"
    echo ""
    read -p "Reinstall/update? (y/N) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi
    
    echo ""
    echo "Backing up existing configuration..."
    cp "$SHELL_CONFIG" "$SHELL_CONFIG.backup-$(date +%Y%m%d-%H%M%S)"
    echo -e "${GREEN}✅ Backup created${NC}"
    echo ""
    
    echo "Removing old function..."
    sed -i.tmp '/^# .*Claude Code in Docker/,/^fi$/d' "$SHELL_CONFIG"
    rm -f "$SHELL_CONFIG.tmp"
    echo -e "${GREEN}✅ Old function removed${NC}"
    echo ""
fi

echo "Downloading claudedev function..."

if ! curl -fsSL "$FUNCTION_URL" >> "$SHELL_CONFIG"; then
    echo -e "${RED}❌ Failed to download function${NC}"
    echo ""
    echo "Please check your internet connection and try again."
    echo "Or install manually from:"
    echo "https://github.com/kaspigoz/claude-code-docker"
    exit 1
fi

echo -e "${GREEN}✅ Function installed to $SHELL_CONFIG${NC}"
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                 Installation Complete!                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo ""
echo "1. Open a NEW terminal window (or tab)"
echo "   The function will be automatically available"
echo ""
echo "2. Or reload current shell:"
echo -e "   ${BLUE}source $SHELL_CONFIG${NC}"
echo ""
echo "3. Navigate to any project:"
echo -e "   ${BLUE}cd /path/to/your/project${NC}"
echo ""
echo "4. Run Claude Code:"
echo -e "   ${BLUE}claudedev${NC}"
echo ""
echo "For help:"
echo -e "   ${BLUE}claudedev --help${NC}"
echo ""
echo "Documentation:"
echo "   https://github.com/kaspigoz/claude-code-docker"
echo ""

read -p "Reload shell configuration now? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # Reload appropriate shell
    if [ "$DETECTED_SHELL" = "zsh" ]; then
        # For zsh, we need to exec zsh or tell user to open new terminal
        echo ""
        echo -e "${GREEN}✅ Configuration updated${NC}"
        echo ""
        echo "Please open a NEW terminal window for changes to take effect."
        echo "Or run: source $SHELL_CONFIG"
    else
        # For bash, source works in current shell
        bash -c "source $SHELL_CONFIG && type claudedev" && echo "" && echo -e "${GREEN}✅ Ready to use!${NC}"
    fi
else
    echo ""
    echo "Remember to open a new terminal or run: source $SHELL_CONFIG"
fi

echo ""
echo "Happy coding! 🚀"
echo ""
ENDINSTALL

chmod +x install.sh

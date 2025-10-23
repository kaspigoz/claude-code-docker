#!/usr/bin/env bash
set -e

REPO_URL="https://raw.githubusercontent.com/kaspigoz/claude-code-docker/main"
FUNCTION_URL="$REPO_URL/claudedev.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

printf "\n"
printf "╔════════════════════════════════════════════════════════════╗\n"
printf "║     Claude Code Docker - Automated Installer              ║\n"
printf "╚════════════════════════════════════════════════════════════╝\n"
printf "\n"

detect_shell() {
    if [ -n "$BASH_VERSION" ]; then
        printf "bash"
    elif [ -n "$ZSH_VERSION" ]; then
        printf "zsh"
    else
        case "$SHELL" in
            */bash) printf "bash" ;;
            */zsh) printf "zsh" ;;
            *) printf "unknown" ;;
        esac
    fi
}

DETECTED_SHELL=$(detect_shell)

if [ "$DETECTED_SHELL" = "unknown" ]; then
    printf "${RED}❌ Unsupported shell${NC}\n"
    printf "This installer supports bash and zsh only.\n"
    printf "\n"
    printf "For manual installation, visit:\n"
    printf "https://github.com/kaspigoz/claude-code-docker\n"
    exit 1
fi

if [ "$DETECTED_SHELL" = "zsh" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    SHELL_CONFIG="$HOME/.bashrc"
fi

printf "${BLUE}Detected shell:${NC} $DETECTED_SHELL\n"
printf "${BLUE}Config file:${NC} $SHELL_CONFIG\n"
printf "\n"

printf "Checking prerequisites...\n"

if ! command -v docker &> /dev/null; then
    printf "${RED}❌ Docker not found${NC}\n"
    printf "\n"
    printf "Please install Docker first:\n"
    printf "  • macOS: brew install --cask docker\n"
    printf "  • Linux: sudo apt-get install docker.io\n"
    printf "  • Windows: https://docker.com/products/docker-desktop\n"
    printf "\n"
    exit 1
fi

if ! docker info &> /dev/null; then
    printf "${YELLOW}⚠️  Docker daemon not running${NC}\n"
    printf "\n"
    printf "Please start Docker:\n"
    printf "  • macOS/Windows: Launch Docker Desktop\n"
    printf "  • Linux: sudo systemctl start docker\n"
    printf "\n"
    read -p "Press Enter when Docker is running, or Ctrl+C to cancel..."
    
    if ! docker info &> /dev/null; then
        printf "${RED}❌ Docker still not running${NC}\n"
        exit 1
    fi
fi

printf "${GREEN}✅ Docker found and running${NC}\n"
printf "\n"

if grep -q "claudedev()" "$SHELL_CONFIG" 2>/dev/null; then
    printf "${YELLOW}⚠️  claudedev function already exists in $SHELL_CONFIG${NC}\n"
    printf "\n"
    read -p "Reinstall/update? (y/N) " -n 1 -r
    printf "\n"
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        printf "Installation cancelled\n"
        exit 0
    fi
    
    printf "\n"
    printf "Backing up existing configuration...\n"
    cp "$SHELL_CONFIG" "$SHELL_CONFIG.backup-$(date +%Y%m%d-%H%M%S)"
    printf "${GREEN}✅ Backup created${NC}\n"
    printf "\n"
    
    printf "Removing old function...\n"
    sed '/^# .*Claude Code in Docker/,/^fi$/d' "$SHELL_CONFIG" > "$SHELL_CONFIG.tmp"
    mv "$SHELL_CONFIG.tmp" "$SHELL_CONFIG"
    printf "${GREEN}✅ Old function removed${NC}\n"
    printf "\n"
fi

printf "Downloading claudedev function...\n"

if ! curl -fsSL "$FUNCTION_URL" >> "$SHELL_CONFIG"; then
    printf "${RED}❌ Failed to download function${NC}\n"
    printf "\n"
    printf "Please check your internet connection and try again.\n"
    printf "Or install manually from:\n"
    printf "https://github.com/kaspigoz/claude-code-docker\n"
    exit 1
fi

printf "${GREEN}✅ Function installed to $SHELL_CONFIG${NC}\n"
printf "\n"

printf "╔════════════════════════════════════════════════════════════╗\n"
printf "║                 Installation Complete!                     ║\n"
printf "╚════════════════════════════════════════════════════════════╝\n"
printf "\n"
printf "Next steps:\n"
printf "\n"
printf "1. Reload your shell configuration:\n"
printf "   ${BLUE}source $SHELL_CONFIG${NC}\n"
printf "\n"
printf "2. Navigate to any project:\n"
printf "   ${BLUE}cd /path/to/your/project${NC}\n"
printf "\n"
printf "3. Run Claude Code:\n"
printf "   ${BLUE}claudedev${NC}\n"
printf "\n"
printf "4. First time? Follow OAuth authentication prompts\n"
printf "\n"
printf "For help:\n"
printf "   ${BLUE}claudedev --help${NC}\n"
printf "\n"
printf "Documentation:\n"
printf "   https://github.com/kaspigoz/claude-code-docker\n"
printf "\n"
printf "To uninstall:\n"
printf "   curl -fsSL https://raw.githubusercontent.com/kaspigoz/claude-code-docker/main/uninstall.sh | bash\n"
printf "\n"

read -p "Reload shell configuration now? (Y/n) " -n 1 -r
printf "\n"
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    if [ "$DETECTED_SHELL" = "zsh" ]; then
        zsh -c "source $SHELL_CONFIG && type claudedev"
    else
        bash -c "source $SHELL_CONFIG && type claudedev"
    fi
    
    printf "\n"
    printf "${GREEN}✅ Shell configuration reloaded${NC}\n"
    printf "\n"
    printf "You can now run 'claudedev' in any project!\n"
else
    printf "\n"
    printf "Remember to run: source $SHELL_CONFIG\n"
fi

printf "\n"
printf "Happy coding! 🚀\n"
printf "\n"

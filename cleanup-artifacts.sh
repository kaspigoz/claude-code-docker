#!/usr/bin/env bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         Claude Artifact Cleanup Tool                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "1) Current directory only"
echo "2) Specify directory"
echo "3) Search home directory"
echo ""
read -p "Choose (1-3): " choice
echo ""

case $choice in
    1)
        echo "Cleaning: $(pwd)"
        find . -maxdepth 2 -type f \( -iname "claude.md" \) -delete 2>/dev/null
        find . -maxdepth 2 -type d -name ".claude" -exec rm -rf {} + 2>/dev/null
        echo -e "${GREEN}✅ Done${NC}"
        ;;
    2)
        read -p "Directory path: " path
        [ ! -d "$path" ] && echo -e "${RED}Not found${NC}" && exit 1
        find "$path" -type f \( -iname "claude.md" \) -delete 2>/dev/null
        find "$path" -type d -name ".claude" -exec rm -rf {} + 2>/dev/null
        echo -e "${GREEN}✅ Done${NC}"
        ;;
    3)
        echo -e "${YELLOW}⚠️  Searching entire home...${NC}"
        read -p "Continue? (y/N) " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
        find "$HOME" -type f \( -iname "claude.md" \) -delete 2>/dev/null
        find "$HOME" -type d -name ".claude" -exec rm -rf {} + 2>/dev/null
        echo -e "${GREEN}✅ Done${NC}"
        ;;
    *)
        echo "Invalid"
        exit 1
        ;;
esac

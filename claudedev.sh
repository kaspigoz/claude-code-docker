#!/usr/bin/env bash

claudedev() {
    local IMAGE_NAME="claude-code"
    local DOCKERFILE_DIR="$HOME/claude-docker"
    local FORCE_BUILD=false
    local AUTO_GIT_EXCLUDE=true
    
    case "$1" in
        --help|-h)
            echo "╔════════════════════════════════════════════════════════════╗"
            echo "║           Claude Code in Docker - Usage Guide             ║"
            echo "╚════════════════════════════════════════════════════════════╝"
            echo ""
            echo "📦 Start Claude Code in isolated Docker container"
            echo ""
            echo "Usage: claudedev [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  (none)       Start in current directory"
            echo "  --rebuild    Force rebuild image"
            echo "  --clean      Remove and rebuild"
            echo "  --version    Show image info"
            echo "  --help       Show this help"
            echo ""
            echo "Works anywhere on your system. No configuration needed."
            echo ""
            return 0
            ;;
        --version|-v)
            if docker image inspect "$IMAGE_NAME" &> /dev/null; then
                echo "📦 Claude Code Docker Image"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                docker image inspect "$IMAGE_NAME" --format='Created: {{.Created}}'
                docker image inspect "$IMAGE_NAME" --format='Size: {{.Size}} bytes'
            else
                echo "❌ Image not built yet"
                echo "💡 Run 'claudedev' to build"
            fi
            return 0
            ;;
        --clean)
            echo "🧹 Cleaning..."
            docker rmi "$IMAGE_NAME" 2>/dev/null && echo "✅ Image removed"
            FORCE_BUILD=true
            ;;
        --rebuild)
            FORCE_BUILD=true
            echo "🔄 Rebuilding..."
            ;;
        --auth-reset)
            echo "🔐 Resetting authentication..."
            docker volume rm claude-auth 2>/dev/null && echo "✅ Auth cleared" || echo "ℹ️  No auth"
            return 0
            ;;
    esac
    
    if ! docker info &> /dev/null; then
        echo "❌ Docker is not running"
        echo ""
        echo "Start Docker and try again"
        return 1
    fi
    
    if [ "$AUTO_GIT_EXCLUDE" = true ] && [ -d .git ]; then
        local GIT_EXCLUDE_FILE=".git/info/exclude"
        local CLAUDE_PATTERNS=(
            "# Claude Code artifacts (added by claudedev)"
            "CLAUDE.md"
            "Claude.md"
            "claude.md"
            ".claude/"
            "*.claude.md"
        )
        
        if [ ! -f "$GIT_EXCLUDE_FILE" ] || ! grep -q "Claude Code artifacts" "$GIT_EXCLUDE_FILE" 2>/dev/null; then
            echo "🔧 Configuring .git/info/exclude..."
            mkdir -p "$(dirname "$GIT_EXCLUDE_FILE")"
            echo "" >> "$GIT_EXCLUDE_FILE"
            for pattern in "${CLAUDE_PATTERNS[@]}"; do
                echo "$pattern" >> "$GIT_EXCLUDE_FILE"
            done
            echo "✅ Git exclude configured"
            echo ""
        fi
    fi
    
    if [ "$FORCE_BUILD" = true ] || ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
        [ "$FORCE_BUILD" = false ] && echo "🔍 Image not found" && echo "📦 Auto-provisioning..."
        echo ""
        
        [ ! -d "$DOCKERFILE_DIR" ] && mkdir -p "$DOCKERFILE_DIR"
        
        if [ ! -f "$DOCKERFILE_DIR/Dockerfile" ]; then
            cat > "$DOCKERFILE_DIR/Dockerfile" << 'DOCKERFILE_END'
FROM node:20-slim

RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://claude.ai/install.sh | bash

WORKDIR /workspace
ENV PATH="/root/.local/bin:${PATH}"
CMD ["/bin/bash"]
DOCKERFILE_END
        fi
        
        echo "🔨 Building image (2-5 minutes)..."
        
        local BUILD_FLAGS="-t $IMAGE_NAME"
        [ "$FORCE_BUILD" = true ] && BUILD_FLAGS="--no-cache $BUILD_FLAGS"
        
        if docker build $BUILD_FLAGS "$DOCKERFILE_DIR"; then
            echo ""
            echo "✅ Build complete!"
            echo ""
        else
            echo "❌ Build failed"
            return 1
        fi
    fi
    
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Claude Code - Docker Container                ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║ Project: $(pwd | sed "s|$HOME|~|")"
    echo "║ Auth: claude-auth volume"
    echo "║ Port: 8484"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    docker run -it --rm \
        --name claude-dev \
        -v "$(pwd):/workspace" \
        -v claude-auth:/root/.claude \
        -p 8484:8484 \
        "$IMAGE_NAME"
    
    local EXIT_CODE=$?
    echo ""
    echo "👋 Container exited"
    [ $EXIT_CODE -eq 0 ] && echo "✅ Changes saved"
    echo ""
    
    return $EXIT_CODE
}

if [ -n "$BASH_VERSION" ]; then
    complete -W "--help --rebuild --clean --version --auth-reset" claudedev
fi

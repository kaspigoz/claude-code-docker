#!/usr/bin/env bash

# Helper function to find an available port starting from a base port
find_available_port() {
    local base_port=$1
    local port=$base_port
    local max_attempts=100

    while [ $((port - base_port)) -lt $max_attempts ]; do
        if ! nc -z localhost $port 2>/dev/null && ! docker ps --format '{{.Ports}}' | grep -q ":${port}->"; then
            echo $port
            return 0
        fi
        port=$((port + 1))
    done

    # Fallback to base port if no available port found
    echo $base_port
}

claudedev() {
    local IMAGE_NAME="claude-code"
    local DOCKERFILE_DIR="$HOME/claude-docker"
    local FORCE_BUILD=false
    local AUTO_GIT_EXCLUDE=true

    # Multi-instance support: Generate unique container name and port
    # Use directory hash + timestamp to ensure uniqueness even in same directory
    local DIR_HASH=""
    if command -v md5sum &> /dev/null; then
        DIR_HASH=$(echo "$(pwd)" | md5sum | cut -c1-8)
    elif command -v md5 &> /dev/null; then
        DIR_HASH=$(echo "$(pwd)" | md5 | cut -c1-8)
    else
        # Fallback: use simple hash of pwd
        DIR_HASH=$(echo "$(pwd)" | cksum | cut -d' ' -f1)
    fi

    local TIMESTAMP=$(date +%s%N 2>/dev/null | cut -c1-13 || date +%s)  # milliseconds or seconds
    local UNIQUE_ID="${DIR_HASH}-${TIMESTAMP}"
    local CONTAINER_NAME="claude-dev-${UNIQUE_ID}"
    local OAUTH_PORT=$(find_available_port 8484)
    
    case "$1" in
        --help|-h)
            echo "╔════════════════════════════════════════════════════════════╗"
            echo "║           Claude Code in Docker - Usage Guide             ║"
            echo "╚════════════════════════════════════════════════════════════╝"
            echo ""
            echo "📦 Start Claude Code in isolated Docker container"
            echo "✨ Multi-instance support: Run in multiple directories simultaneously"
            echo ""
            echo "Usage: claudedev [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  (none)         Start in current directory"
            echo "  --rebuild      Force rebuild image"
            echo "  --clean        Remove and rebuild"
            echo "  --cleanup      Remove all claude-dev containers"
            echo "  --auth-reset   Clear authentication"
            echo "  --version      Show image info"
            echo "  --help         Show this help"
            echo ""
            echo "Multi-Instance:"
            echo "  Each instance gets unique container name and OAuth port"
            echo "  Run multiple instances simultaneously (same or different directories)"
            echo "  Authentication is shared across all instances"
            echo "  Containers auto-cleanup on exit (--rm flag)"
            echo ""
            return 0
            ;;
        --version|-v)
            if docker image inspect claude-code &> /dev/null; then
                echo "📦 Claude Code Docker Image"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                docker image inspect claude-code --format='Created: {{.Created}}'
                docker image inspect claude-code --format='Size: {{.Size}} bytes'
            else
                echo "❌ Image not built yet"
            fi
            return 0
            ;;
        --clean)
            echo "🧹 Cleaning..."
            docker rmi claude-code 2>/dev/null && echo "✅ Image removed"
            FORCE_BUILD=true
            ;;
        --rebuild)
            FORCE_BUILD=true
            ;;
        --auth-reset)
            docker volume rm claude-auth 2>/dev/null && echo "✅ Auth cleared"
            return 0
            ;;
        --cleanup)
            echo "🧹 Cleaning up claude-dev containers..."
            docker ps -a --filter "name=claude-dev" --format "{{.Names}}" | while read -r container; do
                docker rm -f "$container" 2>/dev/null && echo "  ✅ Removed: $container"
            done
            echo "✅ Cleanup complete"
            return 0
            ;;
    esac
    
    if ! docker info &> /dev/null; then
        echo "❌ Docker is not running"
        return 1
    fi
    
    if [ "$AUTO_GIT_EXCLUDE" = true ] && [ -d .git ]; then
        local GIT_EXCLUDE_FILE=".git/info/exclude"
        if [ ! -f "$GIT_EXCLUDE_FILE" ] || ! grep -q "Claude Code artifacts" "$GIT_EXCLUDE_FILE" 2>/dev/null; then
            echo "🔧 Configuring .git/info/exclude..."
            mkdir -p "$(dirname "$GIT_EXCLUDE_FILE")"
            {
                echo ""
                echo "# Claude Code artifacts (added by claudedev)"
                echo "CLAUDE.md"
                echo "Claude.md"
                echo "claude.md"
                echo ".claude/"
                echo "*.claude.md"
            } >> "$GIT_EXCLUDE_FILE"
            echo "✅ Git exclude configured"
            echo ""
        fi
    fi
    
    if [ "$FORCE_BUILD" = true ] || ! docker image inspect claude-code &> /dev/null; then
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
        
        echo "🔨 Building Docker image (2-5 minutes)..."
        echo ""
        
        # CORRECTED: Proper docker build with quoted variables
        if [ "$FORCE_BUILD" = true ]; then
            docker build --no-cache -t claude-code "$DOCKERFILE_DIR"
        else
            docker build -t claude-code "$DOCKERFILE_DIR"
        fi
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Build complete!"
            echo ""
        else
            echo ""
            echo "❌ Build failed"
            return 1
        fi
    fi
    
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Claude Code - Docker Container                ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║ Project: $(pwd | sed "s|$HOME|~|")"
    echo "║ Container: ${CONTAINER_NAME}"
    echo "║ Auth: claude-auth volume (shared)"
    echo "║ OAuth Port: ${OAUTH_PORT}"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Multi-instance support: Use unique container name and port binding
    docker run -it --rm \
        --name "${CONTAINER_NAME}" \
        -v "$(pwd):/workspace" \
        -v claude-auth:/root \
        -p "${OAUTH_PORT}:8484" \
        -e "CLAUDE_OAUTH_PORT=${OAUTH_PORT}" \
        claude-code
    
    local EXIT_CODE=$?
    echo ""
    echo "👋 Container exited"
    [ $EXIT_CODE -eq 0 ] && echo "✅ Changes saved"
    echo ""
    
    return $EXIT_CODE
}

if [ -n "$BASH_VERSION" ]; then
    complete -W "--help --rebuild --clean --cleanup --auth-reset --version" claudedev
fi

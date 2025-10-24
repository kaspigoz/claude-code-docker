# Claude Code in Docker with OAuth
### Professional Implementation Guide

---

## 📖 Table of Contents

- [Overview](#overview)
- [Key Benefits](#key-benefits)
- [Why This Approach?](#why-this-approach)
- [Prerequisites](#prerequisites)
- [Implementation](#implementation)
- [Git Integration & Version Control](#git-integration--version-control)
- [Usage Patterns](#usage-patterns)
- [Command Reference](#command-reference)
- [Production Use Cases](#production-use-cases)
- [Troubleshooting Guide](#troubleshooting-guide)
- [Complete Removal](#complete-removal)
- [Architecture Benefits](#architecture-benefits)
- [Advanced Configurations](#advanced-configurations)
- [Quick Start Summary](#quick-start-summary)

---

## Overview

> **Core Principle:** Run `claudedev` in any project directory. That's it. No configuration, no assumptions about where your code lives, no forced directory structure.

This guide demonstrates a **production-ready approach** to running Claude Code in complete isolation using Docker. A single, self-provisioning shell function automatically handles setup, build, deployment, and local git configuration—requiring zero manual configuration.

<details>
<summary><b>🎯 What This Guide Covers</b></summary>

- Complete Docker-based isolation for Claude Code
- OAuth authentication with session persistence
- Automatic local git configuration (`.git/info/exclude`)
- Works in any directory structure
- Zero host system modifications
- Professional multi-client workflow support

</details>

---

## Key Benefits

✅ Complete system isolation
✅ Zero global installations
✅ Works in any directory structure
✅ Perfect for scattered projects
✅ Ideal for client work
✅ Instant cleanup capability
✅ Automatic local git configuration (no repository pollution)


---

## Why This Approach?

<details>
<summary><b>🔒 For Security-Conscious Developers</b></summary>

- No global npm packages with potential vulnerabilities
- Sandboxed execution environment
- Per-project isolation
- No elevated permissions required
- Clean audit trail

</details>

<details>
<summary><b>📁 For Developers with Diverse Project Locations</b></summary>

- Works wherever your projects live
- No forced directory structure
- Client work in `~/clients/acme/`
- Personal projects in `~/code/`
- Open source in `~/github/`
- Legacy work in `~/Desktop/old-stuff/`
- **All work the same way**

</details>

<details>
<summary><b>👥 For Multi-Client Scenarios</b></summary>

- Separate containers per project
- No cross-project contamination
- Easy context switching
- Clean separation of credentials
- Professional boundaries maintained

</details>

<details>
<summary><b>🛡️ For System Integrity</b></summary>

- Host machine remains pristine
- No PATH pollution
- No config file clutter
- Reversible in seconds
- No permission conflicts

</details>

<details>
<summary><b>📋 For Compliance & Governance</b></summary>

- Auditable environment
- Controlled tool versions
- Documented dependencies
- Isolated execution
- Clean removal capability

</details>

<details>
<summary><b>🎯 For Version Control Hygiene</b></summary>

- Personal exclusions via `.git/info/exclude` (not tracked in repo)
- Claude artifacts excluded from commits
- No pollution of project `.gitignore`
- Individual developer preferences respected
- Clean repository hygiene

</details>


---

## Prerequisites

### 1. Install Docker

<details>
<summary><b>🍎 macOS</b></summary>

```bash
brew install --cask docker
# Launch Docker Desktop from Applications
# Wait for "Docker Desktop is running" in menu bar
```

</details>

<details>
<summary><b>🐧 Linux (Ubuntu/Debian)</b></summary>

```bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
# Log out and back in
```

</details>

<details>
<summary><b>🪟 Windows</b></summary>

1. Download Docker Desktop: https://www.docker.com/products/docker-desktop
2. Install and restart
3. Enable WSL 2 if prompted

</details>

**Verify Installation:**

```bash
docker --version
docker run hello-world
```

### 2. Claude Pro or Max Subscription

> Subscribe at [claude.ai](https://claude.ai)

- **Pro:** $20/month (~45 messages per 5 hours)
- **Max:** $100/month (~225 messages per 5 hours)


---

## Implementation

### Single-Step Setup

#### Step 1: Open Shell Configuration

```bash
# For bash users:
nano ~/.bashrc

# For zsh users (macOS default):
nano ~/.zshrc

# Or use preferred editor:
vim ~/.bashrc
code ~/.bashrc
```

#### Step 2: Add the Complete Function

<details>
<summary><b>📋 Click to view the complete <code>claudedev()</code> function</b></summary>
bash# ============================================================================
# Claude Code in Docker - Auto-provisioning Function
# ============================================================================
# This function automatically:
# - Creates the Dockerfile if missing
# - Builds the Docker image if missing
# - Starts Claude Code in an isolated container
# - Persists authentication across sessions
# - Mounts the current project directory (wherever you are)
# - Configures .git/info/exclude for Claude artifacts (local only)
#
# Works in ANY directory - no configuration needed
#
# Usage:
#   claudedev              # Start in current directory
#   claudedev --rebuild    # Force rebuild image
#   claudedev --help       # Show help
#   claudedev --clean      # Remove and rebuild
#   claudedev --version    # Show image info
# ============================================================================

claudedev() {
    local IMAGE_NAME="claude-code"
    local DOCKERFILE_DIR="$HOME/claude-docker"
    local FORCE_BUILD=false
    local AUTO_GIT_EXCLUDE=true  # Set to false to disable automatic git exclude updates
    
    # ========================================
    # Parse command line arguments
    # ========================================
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
            echo "  (none)       Start Claude Code in current directory"
            echo "  --rebuild    Force rebuild Docker image (get updates)"
            echo "  --clean      Remove old image and rebuild fresh"
            echo "  --version    Show Docker image information"
            echo "  --help       Show this help message"
            echo ""
            echo "Works in any project, anywhere on your system."
            echo "No configuration required."
            echo ""
            echo "Examples:"
            echo "  cd ~/code/my-app && claudedev"
            echo "  cd ~/clients/acme/api && claudedev"
            echo "  cd /wherever/your/project/lives && claudedev"
            echo ""
            echo "First run will:"
            echo "  • Create ~/claude-docker/Dockerfile automatically"
            echo "  • Build Docker image (takes 2-5 minutes)"
            echo "  • Configure .git/info/exclude for Claude artifacts (local only)"
            echo "  • Start container and prompt for OAuth authentication"
            echo ""
            echo "Subsequent runs:"
            echo "  • Start instantly (image cached, auth persisted)"
            echo ""
            echo "Git Integration:"
            echo "  • Automatically adds Claude artifacts to .git/info/exclude"
            echo "  • This is LOCAL only - does not affect the repository"
            echo "  • Excludes: CLAUDE.md, Claude.md, claude.md, .claude/"
            echo "  • Your personal preference - not shared with others"
            echo "  • Disable by setting AUTO_GIT_EXCLUDE=false in function"
            echo ""
            return 0
            ;;
        --version|-v)
            if docker image inspect "$IMAGE_NAME" &> /dev/null; then
                echo "📦 Claude Code Docker Image"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "Image: $IMAGE_NAME"
                docker image inspect "$IMAGE_NAME" --format='Created: {{.Created}}' 
                docker image inspect "$IMAGE_NAME" --format='Size: {{.Size}} bytes'
                echo ""
                echo "Dockerfile: $DOCKERFILE_DIR/Dockerfile"
                if docker volume inspect claude-auth &> /dev/null; then
                    echo "Auth volume: claude-auth (configured)"
                else
                    echo "Auth volume: claude-auth (not yet configured)"
                fi
            else
                echo "❌ Image not built yet"
                echo "💡 Run 'claudedev' to build automatically"
            fi
            return 0
            ;;
        --clean)
            echo "🧹 Cleaning up old image..."
            docker rmi "$IMAGE_NAME" 2>/dev/null && echo "✅ Image removed"
            echo ""
            FORCE_BUILD=true
            ;;
        --rebuild)
            FORCE_BUILD=true
            echo "🔄 Force rebuild requested..."
            echo ""
            ;;
        --auth-reset)
            echo "🔐 Resetting authentication..."
            if docker volume rm claude-auth 2>/dev/null; then
                echo "✅ Authentication cleared"
                echo "💡 Next run will prompt for OAuth login"
            else
                echo "ℹ️  No authentication to clear"
            fi
            return 0
            ;;
    esac
    
    # ========================================
    # Pre-flight checks
    # ========================================
    if ! docker info &> /dev/null; then
        echo "❌ Docker is not running"
        echo ""
        echo "Please start Docker:"
        echo "  • macOS: Open Docker Desktop from Applications"
        echo "  • Linux: sudo systemctl start docker"
        echo "  • Windows: Start Docker Desktop"
        echo ""
        return 1
    fi
    
    # ========================================
    # Configure .git/info/exclude for Claude artifacts
    # ========================================
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
        
        local NEEDS_UPDATE=false
        
        # Check if patterns are missing
        if [ ! -f "$GIT_EXCLUDE_FILE" ] || ! grep -q "Claude Code artifacts" "$GIT_EXCLUDE_FILE" 2>/dev/null; then
            NEEDS_UPDATE=true
        fi
        
        # Add patterns if needed
        if [ "$NEEDS_UPDATE" = true ]; then
            echo "🔧 Configuring .git/info/exclude for Claude artifacts..."
            echo "   (This is local only - not tracked in repository)"
            
            # Ensure .git/info directory exists
            mkdir -p "$(dirname "$GIT_EXCLUDE_FILE")"
            
            # Add patterns
            echo "" >> "$GIT_EXCLUDE_FILE"
            for pattern in "${CLAUDE_PATTERNS[@]}"; do
                echo "$pattern" >> "$GIT_EXCLUDE_FILE"
            done
            echo "✅ Git exclude configured (Claude artifacts hidden locally)"
            echo ""
        fi
    fi
    
    # ========================================
    # Auto-provision: Create Dockerfile
    # ========================================
    if [ "$FORCE_BUILD" = true ] || ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
        if [ "$FORCE_BUILD" = false ]; then
            echo "🔍 Claude Code image not found"
            echo "📦 Auto-provisioning Docker environment..."
        else
            echo "🔨 Rebuilding Claude Code image..."
        fi
        echo ""
        
        # Create directory if needed
        if [ ! -d "$DOCKERFILE_DIR" ]; then
            echo "📁 Creating $DOCKERFILE_DIR..."
            mkdir -p "$DOCKERFILE_DIR"
        fi
        
        # Create Dockerfile if needed
        if [ ! -f "$DOCKERFILE_DIR/Dockerfile" ]; then
            echo "📝 Creating Dockerfile..."
            cat > "$DOCKERFILE_DIR/Dockerfile" << 'DOCKERFILE_END'
# ============================================================================
# Claude Code Docker Environment
# ============================================================================
# Base: Node.js 20 (slim variant for smaller size)
# Includes: Claude Code CLI + Git
# Auto-generated by claudedev() shell function
# ============================================================================

FROM node:20-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code using official installer
RUN curl -fsSL https://claude.ai/install.sh | bash

# Set up workspace
WORKDIR /workspace

# Add Claude Code to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Default command: bash shell
CMD ["/bin/bash"]
DOCKERFILE_END
            echo "✅ Dockerfile created at $DOCKERFILE_DIR/Dockerfile"
            echo ""
        fi
        
        # Build the image
        echo "🔨 Building Docker image (this will take 2-5 minutes first time)..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        local BUILD_FLAGS="-t $IMAGE_NAME"
        if [ "$FORCE_BUILD" = true ]; then
            BUILD_FLAGS="--no-cache $BUILD_FLAGS"
        fi
        
        if docker build $BUILD_FLAGS "$DOCKERFILE_DIR" 2>&1 | while IFS= read -r line; do echo "  $line"; done; then
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "✅ Build complete!"
            echo ""
            
            # Check if auth exists
            if ! docker volume inspect claude-auth &> /dev/null 2>&1; then
                echo "ℹ️  First time setup:"
                echo "   Authentication required (one-time OAuth setup)"
                echo "   1. Inside container, run: claude"
                echo "   2. Choose option 2 (Pro/Max subscription)"
                echo "   3. Authenticate in browser"
                echo "   4. Authentication persists for future sessions"
                echo ""
            fi
            
            echo "🚀 Starting container..."
            echo ""
        else
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "❌ Build failed"
            echo ""
            echo "Troubleshooting:"
            echo "  • Check Docker has internet access"
            echo "  • Try: claudedev --clean"
            echo "  • Check logs above for specific errors"
            echo ""
            return 1
        fi
    fi
    
    # ========================================
    # Run the container
    # ========================================
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Claude Code - Docker Container                ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║ Project: $(pwd | sed "s|$HOME|~|")"
    echo "║ Auth: claude-auth volume (persisted)"
    echo "║ Port: 8484 (for OAuth)"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║ Inside container:                                          ║"
    echo "║   • Run 'claude' to start Claude Code                      ║"
    echo "║   • Your project files are in /workspace                   ║"
    echo "║   • Type 'exit' to leave container                         ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    docker run -it --rm \
        --name claude-dev \
        -v "$(pwd):/workspace" \
        -v claude-auth:/root/.claude \
        -p 8484:8484 \
        "$IMAGE_NAME"
    
    # ========================================
    # Post-exit message
    # ========================================
    local EXIT_CODE=$?
    echo ""
    echo "👋 Container exited"
    if [ $EXIT_CODE -eq 0 ]; then
        echo "✅ All changes saved to $(pwd)"
    else
        echo "⚠️  Exit code: $EXIT_CODE"
    fi
    echo ""
    
    return $EXIT_CODE
}

# Optional: Add autocomplete hints (bash only)
if [ -n "$BASH_VERSION" ]; then
    complete -W "--help --rebuild --clean --version --auth-reset" claudedev
fi
```

</details>

#### Step 3: Activate Configuration

```bash
# Save the file (nano: Ctrl+X, Y, Enter)

# Load immediately
source ~/.bashrc  # or source ~/.zshrc

# Verify installation
type claudedev
```

---

## Git Integration & Version Control

### Understanding `.git/info/exclude` vs `.gitignore`

> **Why `.git/info/exclude` is better for personal tooling:**

| Feature | `.git/info/exclude` | `.gitignore` |
|---------|---------------------|--------------|
| **Tracked in repo** | ❌ No (local only) | ✅ Yes (shared) |
| **Affects others** | ❌ No | ✅ Yes |
| **Personal preferences** | ✅ Perfect for | ❌ Not ideal |
| **Project standards** | ❌ Not for | ✅ Perfect for |
| **Merge conflicts** | ❌ Never | ⚠️ Possible |
| **Pollutes repo** | ❌ No | ⚠️ Can |

**Best practice:**

- **Use `.git/info/exclude` for:** Personal tooling preferences (IDEs, Claude Code, etc.)
- **Use `.gitignore` for:** Project-level exclusions (build artifacts, dependencies, etc.)

---

### Automatic `.git/info/exclude` Configuration

The `claudedev` function automatically configures `.git/info/exclude` in the current project:

**Automatically excluded files (local only):**

- `CLAUDE.md` - Claude's project context file
- `Claude.md` - Case variation
- `claude.md` - Lowercase variation
- `.claude/` - Project-specific Claude directory
- `*.claude.md` - Any Claude markdown files

**When it runs:**

- ✅ Automatically when you run `claudedev` in any git repository
- ✅ Only if the current directory contains a `.git` folder
- ✅ Creates `.git/info/exclude` if it doesn't exist
- ✅ Appends patterns if file exists but lacks Claude entries
- ✅ Does not affect the repository - completely local to this project

**Example output:**

```bash
cd /wherever/your/project/is
claudedev

🔧 Configuring .git/info/exclude for Claude artifacts...
   (This is local only - not tracked in repository)
✅ Git exclude configured (Claude artifacts hidden locally)
```

**Verification:**

```bash
# Check .git/info/exclude contents (local file, not in repo)
cat .git/info/exclude

# Should include:
# Claude Code artifacts (added by claudedev)
# CLAUDE.md
# Claude.md
# claude.md
# .claude/
# *.claude.md

# Verify these files are ignored
touch CLAUDE.md
git status
# CLAUDE.md should NOT appear in untracked files
```

---

### Key Advantages of This Approach

**For individual developers:**

- Personal tool preferences don't clutter project `.gitignore`
- No need to coordinate with anyone on personal tooling
- Each project can have different local exclusions
- No merge conflicts from `.gitignore` changes
- Works in every project, wherever it lives

**For consultancies:**

- Client repositories remain unpolluted
- Professional boundaries maintained
- No evidence of specific tooling in client repos
- Easy to work across different client standards
- Works seamlessly across scattered client projects

---

### Manual Configuration (Optional)
If AUTO_GIT_EXCLUDE=false is set, or for additional control:
bash# Add to .git/info/exclude manually in current project
cat >> .git/info/exclude << 'EOF'

# Claude Code artifacts
CLAUDE.md
Claude.md
claude.md
.claude/
*.claude.md
EOF

# No commit needed - this file is never tracked
Global Exclude Pattern (Alternative Approach)
For exclusion across ALL repositories everywhere:
bash# Create global git exclude file
cat >> ~/.gitignore_global << 'EOF'

# Claude Code artifacts
CLAUDE.md
Claude.md
claude.md
.claude/
*.claude.md
EOF

# Configure git to use global exclude
git config --global core.excludesfile ~/.gitignore_global
Note: The function uses per-project .git/info/exclude by default, which is more targeted and appropriate for most use cases.
Disabling Auto-Configuration
To disable automatic .git/info/exclude updates:
bash# Edit the claudedev function in ~/.bashrc
nano ~/.bashrc

# Find this line:
local AUTO_GIT_EXCLUDE=true

# Change to:
local AUTO_GIT_EXCLUDE=false

# Save and reload
source ~/.bashrc
Checking What's Excluded
bash# Test if a file would be ignored
git check-ignore -v CLAUDE.md

# Should show:
# .git/info/exclude:2:CLAUDE.md    CLAUDE.md

# View all your local exclusions in this project
cat .git/info/exclude

# List all exclusions (including .gitignore)
git status --ignored

---

## Usage Patterns

### Initial Setup (Automatic)

```bash
# Navigate to ANY project, ANYWHERE on your system
cd /path/to/your/project

# Execute - everything provisions automatically
claudedev
```

**Automated process:**
```
🔧 Configuring .git/info/exclude for Claude artifacts...
   (This is local only - not tracked in repository)
✅ Git exclude configured (Claude artifacts hidden locally)

🔍 Claude Code image not found
📦 Auto-provisioning Docker environment...

📁 Creating /home/user/claude-docker...
📝 Creating Dockerfile...
✅ Dockerfile created at /home/user/claude-docker/Dockerfile

🔨 Building Docker image (this will take 2-5 minutes first time)...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  [+] Building 145.2s (8/8) FINISHED
  => [internal] load build definition
  => [1/4] FROM docker.io/library/node:20-slim
  => [2/4] RUN apt-get update && apt-get install...
  => [3/4] RUN curl -fsSL https://claude.ai/install.sh | bash
  => [4/4] WORKDIR /workspace
  => exporting to image

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Build complete!

ℹ️  First time setup:
   Authentication required (one-time OAuth setup)
   1. Inside container, run: claude
   2. Choose option 2 (Pro/Max subscription)
   3. Authenticate in browser
   4. Authentication persists for future sessions

🚀 Starting container...

╔════════════════════════════════════════════════════════════╗
║              Claude Code - Docker Container                ║
╠════════════════════════════════════════════════════════════╣
║ Project: /path/to/your/project
║ Auth: claude-auth volume (persisted)
║ Port: 8484 (for OAuth)
╠════════════════════════════════════════════════════════════╣
║ Inside container:                                          ║
║   • Run 'claude' to start Claude Code                      ║
║   • Your project files are in /workspace                   ║
║   • Type 'exit' to leave container                         ║
╚════════════════════════════════════════════════════════════╝

root@abc123:/workspace#
```

---

### OAuth Authentication (One-Time)

```bash
# Inside the container
claude
```
```
Welcome to Claude Code!

How would you like to authenticate?

1. Claude Console (API)
2. Claude App (Pro/Max subscription)
3. AWS Bedrock
4. Google Vertex AI

Select option (1-4): 2
```
```
Opening browser for authentication...

Visit this URL if browser doesn't open automatically:
https://claude.ai/oauth/authorize?...

Waiting for authentication...
```

**Browser authentication flow:**
1. Navigate to claude.ai (automatic or manual URL)
2. Authenticate with existing credentials
3. Authorize application access
4. Redirect to `http://localhost:8484/callback`

**Confirmation:**
```
✓ Authentication successful!
✓ Connected to user@example.com (Pro Plan)
Usage: ~45 messages per 5 hours remaining

>
Validation:
bash> Analyze this project structure

# Claude processes request

> Generate unit tests for the auth module

# Claude generates tests

# Exit when complete
/exit
exit
Daily Workflow (Instant) - Real World Examples
bash# Client work
cd ~/clients/acme/api-gateway
claudedev
claude
# Work...
/exit
exit

# Personal side project
cd ~/code/my-saas-idea
claudedev
claude
# Work...
/exit
exit

# Open source contribution
cd ~/github/awesome-project
claudedev
claude
# Work...
/exit
exit

# Legacy project (we all have them)
cd ~/Desktop/old-consulting-work/2023-project
claudedev
claude
# Work...
/exit
exit

# Wherever your code lives, claudedev works the same

---

## Command Reference

### Primary Commands

```bash
# Start in current directory (wherever you are)
claudedev

# Display comprehensive help
claudedev --help

# Show image information
claudedev --version
```

### Maintenance Operations

```bash
# Force rebuild (retrieve latest updates)
claudedev --rebuild

# Clean rebuild (fresh installation)
claudedev --clean

# Reset authentication credentials
claudedev --auth-reset
```

### Container Operations

```bash
# Start Claude Code
claude

# Exit Claude Code
/exit

# Exit container
exit

# Inspect mounted project
ls -la /workspace

# Verify working directory
pwd  # Returns: /workspace
```

---

## Production Use Cases

### Multi-Client Development (Scattered Projects)

```bash
# Client A - corporate structure
cd ~/work/client-a/backend-api
claudedev
claude
# Development work...
/exit
exit

# Client B - different location
cd ~/consulting/2024/client-b/frontend
claudedev
claude
# Development work...
/exit
exit

# Client C - legacy path
cd /Volumes/External/archived-clients/client-c
claudedev
claude
# Development work...
/exit
exit

# Personal project
cd ~/code/side-hustle
claudedev
claude
# Development work...
/exit
exit

# Shared authentication, isolated execution
# Each project gets its own .git/info/exclude (local only)
# No assumptions about project locations
```

---

### Customizing the Dockerfile

If you need additional tools, you can customize the Dockerfile:

```bash
# Edit the generated Dockerfile
nano ~/claude-docker/Dockerfile

# Example: Add Python support
# Add these lines after the git installation:
#   python3 \
#   python3-pip \
```

**Full example with Python:**

```dockerfile
FROM node:20-slim

RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://claude.ai/install.sh | bash

WORKDIR /workspace
ENV PATH="/root/.local/bin:${PATH}"
CMD ["/bin/bash"]
```

**Rebuild and use:**

```bash
# Rebuild the image
claudedev --rebuild

# Now Python is available in all your projects
```

---

### Container Monitoring

```bash
# View running containers (separate terminal)
docker ps

# Monitor resource usage
docker stats claude-dev

# Inspect container logs
docker logs claude-dev
```

---

## Troubleshooting Guide

### Docker Daemon Issues

```bash
# Verify Docker status
docker info

# Start Docker service
# macOS/Windows: Launch Docker Desktop
# Linux: sudo systemctl start docker

# Retry operation
claudedev
```

---

### Port Conflicts

```bash
# Identify process using port 8484
lsof -i :8484  # macOS/Linux
netstat -ano | findstr :8484  # Windows

# Modify function to use alternative port
# Edit ~/.bashrc, change -p 8484:8484 to -p 8485:8484
```

---

### Build Failures

```bash
# Execute clean rebuild
claudedev --clean

# Verify network connectivity
docker run --rm alpine ping -c 3 google.com

# Check available disk space
docker system df
```

---

### Authentication Expiration

```bash
# Reset session (inside container)
claude
/logout

# Re-authenticate
claude
# Select option 2, complete OAuth flow
```

---

### Credential Issues

```bash
# Clear stored authentication
claudedev --auth-reset

# Fresh authentication
claudedev
claude
# Complete OAuth authentication
```

---

### File Permission Problems

```bash
# Modify function to match user permissions
# Edit ~/.bashrc, add after 'docker run -it --rm \':
--user $(id -u):$(id -g) \

# Complete line becomes:
docker run -it --rm \
    --user $(id -u):$(id -g) \
    --name claude-dev \
```

---

### Git Exclude Not Working

```bash
# Verify git repository exists
ls -la .git

# Check AUTO_GIT_EXCLUDE setting
grep "AUTO_GIT_EXCLUDE" ~/.bashrc

# Verify exclude file exists in this project
cat .git/info/exclude

# Test if pattern works
touch CLAUDE.md
git status  # Should NOT show CLAUDE.md

# Manual update if needed
cat >> .git/info/exclude << 'EOF'

# Claude Code artifacts
CLAUDE.md
Claude.md
claude.md
.claude/
*.claude.md
EOF
```

---

### Claude Files Still Appear in Git Status

```bash
# Check if files were already tracked before exclude was added
git ls-files | grep -i claude

# If files are already tracked, they need to be untracked first
git rm --cached CLAUDE.md Claude.md claude.md
git rm --cached -r .claude/

# Now they'll be excluded going forward
git status  # Should not show Claude files anymore
```

---

## Complete Removal

### Understanding What Gets Removed

**Docker environment:**

- Docker image and volumes (removed during uninstall)
- `~/claude-docker` directory (removed during uninstall)
- Shell function (removed during uninstall)

**Git configuration (per-project):**

- `.git/info/exclude` entries (LOCAL to each project)
- These are NOT in version control
- Must be cleaned per project if desired

**Project artifacts (per-project):**

- `CLAUDE.md` files (generated by Claude Code)
- `.claude/` directories (Claude's working files)
- These are in your working directory

---

### Philosophy: Per-Project Primary

The tool works per-project, so cleanup is per-project. You have three cleanup strategies:

1. **Current project only** (simplest, most common)
2. **Specific projects** (clean only what you want)
3. **Comprehensive search** (optional, for power users)

---

### Strategy 1: Current Project Only (Recommended)

Clean the project you're currently in:

```bash
# Navigate to the project
cd /path/to/project

# Remove Claude artifacts from this project
rm -f CLAUDE.md Claude.md claude.md
rm -rf .claude/

# (Optional) Clean .git/info/exclude in this project
nano .git/info/exclude
# Remove Claude section manually

# That's it for this project
```

> Repeat for each project where you used Claude Code.

---

### Strategy 2: Specific Projects (Selective)

Clean only the projects you specify:
bash# List of your projects
PROJECTS=(
    "$HOME/clients/acme/api"
    "$HOME/code/my-app"
    "$HOME/github/fork-xyz"
    "/Volumes/External/old-work/legacy-app"
)

# Clean each one
for project in "${PROJECTS[@]}"; do
    if [ -d "$project" ]; then
        echo "Cleaning: $project"
        rm -f "$project/CLAUDE.md" "$project/Claude.md" "$project/claude.md"
        rm -rf "$project/.claude/"
    fi
done

echo "✅ Specified projects cleaned"

Strategy 3: Comprehensive Search (Optional, Advanced)
Interactive cleanup - specify where to search:
bashecho "Where should we search for Claude artifacts?"
echo ""
echo "1) Current directory only"
echo "2) Specify a directory to search"
echo "3) Search entire home directory (slow)"
echo ""
read -p "Choose option (1-3): " choice

case $choice in
    1)
        # Current directory
        find . -maxdepth 2 -type f \( -iname "claude.md" -o -iname "CLAUDE.md" \) -delete
        find . -maxdepth 2 -type d -name ".claude" -exec rm -rf {} +
        ;;
    2)
        read -p "Enter directory path: " search_path
        find "$search_path" -type f \( -iname "claude.md" -o -iname "CLAUDE.md" \) -delete
        find "$search_path" -type d -name ".claude" -exec rm -rf {} +
        ;;
    3)
        echo "⚠️  This will search your entire home directory..."
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            find "$HOME" -type f \( -iname "claude.md" -o -iname "CLAUDE.md" \) -delete
            find "$HOME" -type d -name ".claude" -exec rm -rf {} +
        fi
        ;;
esac

Full Uninstallation Process
bash# 1. (Optional) Clean project artifacts using one of the strategies above

# 2. (Optional) Clean .git/info/exclude entries
#    These are per-project and harmless to keep
#    Or manually edit in projects if desired

# 3. Remove authentication volume
docker volume rm claude-auth

# 4. Remove Claude Code image
docker rmi claude-code

# 5. Remove base image (optional)
docker rmi node:20-slim

# 6. Remove Dockerfile directory
rm -rf ~/claude-docker

# 7. Remove shell function
nano ~/.bashrc  # or ~/.zshrc
# Delete entire claudedev() function and autocomplete section
source ~/.bashrc

# 8. Verification
which claudedev  # Expected: not found
docker images | grep claude  # Expected: no output
docker volume ls | grep claude  # Expected: no output

Partial Removal Options
Keep Docker setup, remove only artifacts from specific projects:
bash# Navigate to each project and clean
cd /path/to/project-1
rm -f CLAUDE.md Claude.md claude.md
rm -rf .claude/

cd /path/to/project-2
rm -f CLAUDE.md Claude.md claude.md
rm -rf .claude/

# Docker environment remains intact
# .git/info/exclude entries remain (harmless)
Remove Docker setup, keep all project artifacts:
bash# Keep all Claude.md files and .git/info/exclude (project context preserved)
# Remove only Docker components
docker volume rm claude-auth
docker rmi claude-code
rm -rf ~/claude-docker
# Edit ~/.bashrc to remove function

# All project artifacts remain for reference
Clean specific project only:
bashcd /specific/project/path

# Remove artifacts from this project only
rm -f CLAUDE.md Claude.md claude.md
rm -rf .claude/

# Edit .git/info/exclude if desired
nano .git/info/exclude
# Remove Claude section manually

---

## Architecture Benefits

### System Isolation

✅ Zero host machine modifications
✅ No global package installations
✅ No PATH environment changes
✅ No configuration file pollution
✅ No permission elevation required

### Security Model

✅ Sandboxed execution environment
✅ Per-project isolation
✅ Controlled network access
✅ Auditable container images
✅ Credential segregation

### Reproducibility

✅ Version-controlled Dockerfile
✅ Identical environment across machines
✅ Deterministic builds
✅ CI/CD integration ready

### Operational Excellence

✅ Auto-provisioning capability
✅ Self-healing setup
✅ Minimal user intervention
✅ Single command operation
✅ Complete cleanup in seconds

### Professional Workflow

✅ Works in any directory structure
✅ No assumptions about project locations
✅ Per-project operation by design
✅ Client project separation
✅ Compliance-friendly
✅ Audit trail maintained
✅ Professional boundaries
✅ Easy context switching

### Version Control Integration

✅ Personal exclusions via `.git/info/exclude` (not tracked)
✅ No pollution of project .gitignore
✅ Individual developer preferences respected
✅ No merge conflicts from tooling preferences
✅ Clean repository hygiene
✅ Professional client repository handling

---

## Integration Opportunities

### IDE Integration

**VS Code Remote Containers:**

```json
{
  "name": "Claude Code Dev",
  "dockerFile": "../claude-docker/Dockerfile",
  "mounts": [
    "source=claude-auth,target=/root/.claude"
  ],
  "forwardPorts": [8484]
}
```

**JetBrains Gateway:**

- Configure remote Docker connection
- Mount workspace volume
- Forward OAuth port

---

### CI/CD Pipeline

```yaml
# GitHub Actions example
- name: Run Claude Code analysis
  run: |
    docker run --rm \
      -v $(pwd):/workspace \
      -e ANTHROPIC_API_KEY=${{ secrets.ANTHROPIC_API_KEY }} \
      claude-code \
      bash -c "claude < analysis-prompts.txt"
```

---

### Git Hooks Integration

```bash
# Pre-commit hook to verify Claude files aren't committed
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Check if Claude artifacts are being committed
if git diff --cached --name-only | grep -qiE 'claude\.md$|^\.claude/'; then
    echo "⚠️  WARNING: Claude artifacts detected in commit"
    echo "These should be in .git/info/exclude (local only)"
    echo ""
    echo "To fix:"
    echo "  1. Run 'claudedev' to configure .git/info/exclude"
    echo "  2. Unstage files: git reset HEAD CLAUDE.md .claude/"
    echo ""
    exit 1
fi
EOF

chmod +x .git/hooks/pre-commit
```

---

## Advanced Configurations

### Resource Constraints

```bash
# Modify docker run command with limits:
docker run -it --rm \
    --memory="4g" \
    --cpus="2" \
    --name claude-dev \
    # ... rest of flags
```

---

### Network Isolation

```bash
# Add network restrictions:
docker run -it --rm \
    --network=none \
    # ... rest of flags
    # (Will break OAuth - use for restricted environments)
```

---

### Custom Exclude Patterns

```bash
# Edit function to add project-specific patterns
local CLAUDE_PATTERNS=(
    "# Claude Code artifacts (added by claudedev)"
    "CLAUDE.md"
    "Claude.md"
    "claude.md"
    ".claude/"
    "*.claude.md"
    # Add custom patterns:
    ".claude-temp/"
    "claude-session-*.log"
    ".claude-cache/"
)
Exclude Pattern for Specific File Types
bash# Add to .git/info/exclude for additional exclusions
cat >> .git/info/exclude << 'EOF'

# Claude working files
.claude-workspace/
claude-temp-*.txt
*.claude-backup
EOF

---

## Quick Start Summary

**For developers seeking immediate deployment:**

```bash
# 1. Add function to shell configuration
nano ~/.bashrc  # Paste complete function

# 2. Activate configuration
source ~/.bashrc

# 3. Navigate to ANY project, ANYWHERE
cd /wherever/your/project/lives

# 4. Execute (auto-configures .git/info/exclude locally)
claudedev

# 5. Authenticate (one-time)
claude  # Follow OAuth prompts

# 6. Work
# Use claudedev in any project, anywhere on your system
# No configuration, no assumptions, just works
```

---

## Value Proposition

### For Individual Developers

- **System integrity:** Host environment remains pristine
- **Flexibility:** Easy experimentation without consequences
- **Portability:** Same setup across all machines
- **Peace of mind:** Instant, complete removal capability
- **Git hygiene:** Personal exclusions stay personal (`.git/info/exclude`)
- **No noise:** Project `.gitignore` stays focused on project needs
- **Privacy:** No evidence of tooling choices in repositories
- **Universal:** Works wherever your projects live

### For Consultancies & Agencies

- **Client isolation:** Perfect separation between projects
- **Professionalism:** Clean, controlled environments
- **Compliance:** Auditable, documented tooling
- **Efficiency:** Rapid context switching between clients
- **Repository cleanliness:** No tool artifacts in client repositories
- **Invisible tooling:** Client repos show no evidence of Claude Code usage
- **Professional boundaries:** Clear separation of personal tools from client projects
- **Location agnostic:** Works across scattered client project structures

### For Multi-Machine Workflows

- **Consistency:** Same environment on laptop, desktop, remote servers
- **No sync issues:** Docker image travels with you
- **Quick setup:** New machine productive in 5 minutes
- **No cleanup debt:** Old machines clean up instantly

### For Developers with Scattered Projects

- **No forced structure:** Works wherever your code lives
- **No configuration:** Just run `claudedev` in any project
- **No assumptions:** Tool doesn't dictate how you organize
- **True flexibility:** Client work, personal projects, open source—all the same


---

## Conclusion

This implementation provides a **professional-grade, self-provisioning Claude Code environment** with complete isolation, zero host system impact, intelligent local git configuration, and absolute flexibility regarding project location.

### Key Advantages

- ✅ Automatic setup and tear-down
- ✅ OAuth authentication with persistence
- ✅ Complete system isolation
- ✅ Production-ready architecture
- ✅ Individual developer focused
- ✅ Automatic `.git/info/exclude` configuration (local only)
- ✅ No repository pollution
- ✅ Professional client repository handling
- ✅ Zero impact on project standards
- ✅ Works in any directory, anywhere on your system
- ✅ No assumptions about project structure
- ✅ Per-project operation by design

### Performance Metrics

| Metric | Time |
|--------|------|
| **Deployment time** | Under 5 minutes from zero to production |
| **Maintenance overhead** | Effectively zero—system self-manages |
| **Removal complexity** | 30 seconds for complete cleanup |
| **Setup per project** | Instant (automatic) |

### Philosophy

> **Git Integration:** Automatic local exclusions that never affect the repository or anyone else.

> **Flexibility:** Works wherever your projects live—organized or scattered, client work or personal, any directory structure.

This approach represents **modern development best practices**: containerized, reproducible, isolated, professionally architected, respectful of individual preferences while maintaining project integrity, and completely agnostic about how you organize your work.

The use of `.git/info/exclude` instead of `.gitignore` demonstrates sophisticated understanding of git's exclusion mechanisms. The per-project operation model acknowledges the reality that developers' projects exist in diverse locations across their filesystem, and doesn't impose artificial organizational requirements.

---

**Made with ❤️ for professional developers who value isolation, flexibility, and clean workflows.**

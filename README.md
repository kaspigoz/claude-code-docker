# Claude Code in Docker

This isn't perfect - but I needed something like this - and I created it -- perhaps some of you can use/improve this baseline.
I am SUPER excited about this - because I am always resistant to installing stuff on my host machine.
Now - I can use Claude Code on any Folder/Project with no worries of long lasting side-effects on my OS. (I know - probably OCD)

> Claude Code acces your local codebase
> In complete isolation with zero system impact while
> Insights, improvements, modifications - from outside

Professional Docker-based implementation of Claude Code that works in any project, anywhere on your system—no configuration required.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## ✨ Features

- 🐳 **Complete isolation** - Zero host system modifications
- 🚀 **Auto-provisioning** - One command does everything
- 🔐 **OAuth authentication** - Claude Pro/Max subscription support
- 📁 **Universal** - Works in any directory structure
- 🧹 **Clean** - Personal git exclusions via `.git/info/exclude`
- ⚡ **Instant** - Start coding in seconds

## 🎯 Quick Start

### One-Line Install
```bash
curl -fsSL https://raw.githubusercontent.com/kaspigoz/claude-code-docker/main/install.sh | bash
```

### Usage
```bash
# Navigate to any project
cd /path/to/your/project

# Start Claude Code
claudedev

# First time: Authenticate via browser
# Subsequent runs: Instant access
```

That's it! No configuration, no setup files, no assumptions about where your code lives.

## 🔧 Requirements

- **Docker** (Desktop or Engine)
- **Claude Pro/Max** subscription
- **Bash** or **Zsh** shell

## 📖 How It Works

1. **Single shell function** handles everything
2. **Automatic Dockerfile** generation in `~/claude-docker`
3. **Docker image** built on first run (cached forever)
4. **OAuth credentials** persisted in named volume
5. **Current project** mounted to container
6. **Git exclusions** configured locally (`.git/info/exclude`)

## 🎯 Perfect For

- **Consultants** - Isolated client projects
- **Freelancers** - Clean professional boundaries
- **Developers** - Scattered project structures
- **Multi-machine** - Same environment everywhere

## 📋 Commands
```bash
claudedev              # Start in current directory
claudedev --help       # Show help
claudedev --rebuild    # Update image
claudedev --clean      # Fresh rebuild
claudedev --version    # Image info
claudedev --auth-reset # Clear credentials
```

## 🗑️ Uninstall
```bash
curl -fsSL https://raw.githubusercontent.com/kaspigoz/claude-code-docker/main/uninstall.sh | bash
```

## 📚 Full Documentation

> 📖 **[Read the Complete Implementation Guide →](./GUIDE.md)**

**Includes:**
- 🏗️ Detailed architecture and benefits
- 🔧 Git integration (`.git/info/exclude` vs `.gitignore`)
- 🐛 Comprehensive troubleshooting guide
- ⚙️ Advanced configurations & customization
- 🗑️ Complete removal procedures
- 💼 Production use cases for consultancies

## 🤝 Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md)

## 📄 License

MIT License - see [LICENSE](./LICENSE)

---

**Made with ❤️ for the developer community**

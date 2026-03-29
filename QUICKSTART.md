# MCP Inspector - Quick Start Guide

Get the MCP Inspector web interface running in under 5 minutes!

## For the Web Interface (Demo App)

### Prerequisites
- Ruby 2.7+ installed
- Node.js and npm installed (for MCP servers)
- Bundler installed (`gem install bundler`)

### Quick Start (3 commands)

```bash
# 1. Navigate to the demo app
cd inspector

# 2. Run the start script (installs dependencies and starts server)
bin/start

# 3. Open your browser to http://localhost:3000
```

That's it! You should now see the MCP Inspector web interface.

### What's Included

The demo comes pre-configured with two MCP servers:

1. **filesystem-server** - Interact with files in `/tmp` directory
2. **github-server** - Interact with GitHub (requires GITHUB_TOKEN)

### Your First Test

1. **Create a test file**:
   ```bash
   echo "Hello MCP Inspector!" > /tmp/test.txt
   ```

2. **In the browser**:
   - Select "filesystem-server" from the dropdown
   - Click "List Tools"
   - Find "read_file" tool and click "Execute"
   - Enter: `{"path": "/tmp/test.txt"}`
   - Click "Execute Tool"
   - See your file contents appear!

### Optional: GitHub Server Setup

To use the GitHub server:

```bash
export GITHUB_TOKEN=your_github_token_here
```

Get a token at: https://github.com/settings/tokens

Then restart the server and select "github-server" from the dropdown.

## Integrating Into Your Own Rails App

To add MCP Inspector to your existing Rails application:

1. **Mount the engine** in `config/routes.rb`:
   ```ruby
   mount McpInspector::Web::Engine, at: '/mcp_inspector'
   ```

2. **Require the engine** in `config/application.rb`:
   ```ruby
   require 'mcp_inspector_web'
   ```

3. **Restart your server** and visit `/mcp_inspector`

See [WEB_README.md](WEB_README.md) for complete documentation.

## For the CLI Tool

If you prefer the command-line interface:

```bash
# Install the gem
gem install mcp-inspector

# Create configuration
mcp-inspector config init

# List available tools
mcp-inspector list tools --server filesystem-server

# Execute a tool
mcp-inspector execute read_file --server filesystem-server --args '{"path": "/tmp/test.txt"}'
```

## What's Next?

- **Web Interface Documentation**: See [WEB_README.md](WEB_README.md)
- **CLI Documentation**: See [README.md](README.md)
- **Demo App Details**: See [inspector/README.md](inspector/README.md)
- **Add Your Own MCP Servers**: Edit `.mcp-inspector.json`

## Troubleshooting

### "Command not found: npx"
Install Node.js from https://nodejs.org/

### "Bundle not found"
```bash
gem install bundler
```

### "Connection failed"
Make sure the MCP server is installed:
```bash
npx -y @modelcontextprotocol/server-filesystem /tmp
```

### Need Help?
- Check the comprehensive [WEB_README.md](WEB_README.md)
- Check the demo app [README](inspector/README.md)
- Open an issue on GitHub

## Architecture Overview

```
┌─────────────────────────────────────┐
│   Browser (Web Interface)           │
│   http://localhost:3000              │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Rails Engine (MCP Inspector Web)  │
│   - Controllers                      │
│   - Views (Tailwind CSS)             │
│   - Turbo Streams                    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   MCP Inspector Core                │
│   - Transport Layer                  │
│   - Data Layer                       │
│   - Configuration Management         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   MCP Servers                        │
│   - filesystem-server                │
│   - github-server                    │
│   - your-custom-server               │
└─────────────────────────────────────┘
```

## Key Features

✅ **Zero Configuration** - Pre-configured demo app ready to run
✅ **Interactive UI** - Click, type, execute - no command-line needed
✅ **Real-time Updates** - Turbo Streams for seamless interactions
✅ **Multiple Transports** - stdio, SSE, WebSocket support
✅ **Secure** - CSRF protection, input validation, timeouts
✅ **Extensible** - Add your own MCP servers easily

Happy inspecting! 🔍

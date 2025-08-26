# MCP Inspector

A Ruby gem that provides a command-line tool for connecting to and inspecting MCP (Model Context Protocol) servers. The tool allows you to list and execute tools, read resources, and get prompts from MCP servers with JSON output by default.

## Features

- **Multi-transport support**: Connect to MCP servers via stdio, SSE, or WebSocket
- **Command-based CLI**: Execute operations without persistent sessions
- **JSON configuration**: Configure multiple servers in a single JSON file
- **Structured output**: All output in JSON format for easy parsing and automation
- **Three-layer architecture**: Designed for future web adaptation

## Installation

Install the gem by executing:

```bash
gem install mcp-inspector
```

Or add it to your Gemfile:

```ruby
gem 'mcp-inspector'
```

Then execute:

```bash
bundle install
```

## Quick Start

1. **Create a configuration file:**

```bash
mcp-inspector config init
```

This creates `~/.mcp-inspector.json` with example server configurations.

2. **List available servers:**

```bash
mcp-inspector config list
```

3. **List tools from a server:**

```bash
mcp-inspector list tools --server filesystem-server
```

4. **Execute a tool:**

```bash
mcp-inspector execute read_file --server filesystem-server --args '{"path": "/tmp/test.txt"}'
```

## Configuration

The tool looks for configuration files in this order:

1. Custom path via `--config` flag
2. `./.mcp-inspector.json` (project config)
3. `~/.mcp-inspector.json` (user config)

### Configuration Format

```json
{
  "servers": [
    {
      "name": "filesystem-server",
      "transport": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem"],
      "args": ["/tmp"],
      "env": {}
    },
    {
      "name": "github-server",
      "transport": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    {
      "name": "http-server",
      "transport": "sse",
      "url": "http://localhost:8080/sse"
    }
  ],
  "defaults": {
    "output": "json",
    "pretty": true
  }
}
```

### Transport Types

- **stdio**: Run a command and communicate via stdin/stdout
- **sse**: Connect to Server-Sent Events endpoint
- **websocket**: Connect to WebSocket endpoint

## Usage

### Global Options

- `--config PATH`: Path to config file
- `--server NAME`: Server name from config (required)
- `--output FORMAT`: Output format (json)
- `--pretty`: Pretty print output (default: true)
- `--no-pretty`: Disable pretty printing

### Commands

#### List Resources

```bash
# List all tools
mcp-inspector list tools --server myserver

# List all resources  
mcp-inspector list resources --server myserver

# List all prompts
mcp-inspector list prompts --server myserver
```

#### Execute Operations

```bash
# Execute a tool
mcp-inspector execute tool_name --server myserver --args '{"key": "value"}'

# Read a resource
mcp-inspector read file:///path/to/file --server myserver

# Get a prompt
mcp-inspector prompt prompt_name --server myserver --args '{"key": "value"}'
```

#### Server Information

```bash
# Show server info and capabilities
mcp-inspector info --server myserver
```

#### Configuration Management

```bash
# List configured servers
mcp-inspector config list

# Show server configuration
mcp-inspector config show myserver

# Create example config file
mcp-inspector config init [path]
```

### Output Format

All commands return JSON with a consistent structure:

```json
{
  "status": "success",
  "data": {
    "tools": [...],
    "count": 3
  },
  "metadata": {
    "operation": "list_tools",
    "server": "filesystem-server",
    "timestamp": "2024-01-01T12:00:00Z"
  }
}
```

Error responses:

```json
{
  "status": "error",
  "error": {
    "type": "ConnectionError", 
    "message": "Failed to connect to server"
  },
  "metadata": {
    "operation": "list_tools",
    "server": "filesystem-server",
    "timestamp": "2024-01-01T12:00:00Z"
  }
}
```

## Examples

### Filesystem Server

```bash
# List files in a directory
mcp-inspector list tools --server filesystem-server

# Read a file
mcp-inspector execute read_file --server filesystem-server --args '{"path": "/tmp/example.txt"}'

# Write to a file
mcp-inspector execute write_file --server filesystem-server --args '{"path": "/tmp/output.txt", "content": "Hello World"}'
```

### GitHub Server

```bash
# List repository information
mcp-inspector list resources --server github-server

# Search repositories
mcp-inspector execute search_repositories --server github-server --args '{"query": "ruby mcp"}'
```

## Architecture

The gem uses a three-layer architecture:

1. **Transport Layer**: Handles connections to MCP servers
2. **Data Layer**: Manages configuration and input/output processing  
3. **Presentation Layer**: Formats output for display

This design makes it easy to add new output formats or adapt for web interfaces in the future.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

### Running Tests

```bash
bundle exec rspec
```

### Building the Gem

```bash
gem build mcp-inspector.gemspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/anthropics/mcp-inspector.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
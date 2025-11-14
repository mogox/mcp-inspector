# MCP Inspector Demo Application

This is a sample Rails application demonstrating how to mount and use the MCP Inspector Web Engine.

## Overview

This demo app shows:
- How to mount the MCP Inspector Rails Engine
- How to configure MCP servers
- The full web interface in action
- Integration with existing Rails applications

## Prerequisites

- Ruby 2.7 or higher
- Node.js and npm (for MCP servers)
- Bundler

## Quick Start

### 1. Install Dependencies

From the `inspector/` directory:

```bash
bundle install
```

### 2. Set Up the Database

```bash
rails db:create db:migrate
```

### 3. Configure MCP Servers

The demo includes a sample configuration file `.mcp-inspector.json` with two example servers:

- **filesystem-server**: Interact with the local filesystem (limited to `/tmp`)
- **github-server**: Interact with GitHub (requires GITHUB_TOKEN environment variable)

#### Setting Up GitHub Token (Optional)

If you want to test the GitHub server:

```bash
export GITHUB_TOKEN=your_github_personal_access_token
```

You can create a personal access token at: https://github.com/settings/tokens

### 4. Start the Server

```bash
rails server
```

The application will be available at: http://localhost:3000

Since the root path redirects to the MCP Inspector, you'll immediately see the web interface.

## How It Works

### Mounting the Engine

In `config/routes.rb`:

```ruby
mount McpInspector::Web::Engine, at: "/mcp_inspector"
root to: redirect("/mcp_inspector")
```

### Loading the Engine

In `config/application.rb`:

```ruby
require "mcp_inspector_web"
```

### Gem Configuration

In `Gemfile`:

```ruby
gem "mcp-inspector", path: ".."
```

The path points to the parent directory since this demo is included within the gem itself.

## Using the Interface

### 1. Select a Server

Use the dropdown to select one of the configured MCP servers:
- `filesystem-server`
- `github-server`

### 2. Get Server Info

Click "Get Server Info" to see:
- Server capabilities (tools, resources, prompts support)
- Server metadata
- Raw JSON response

### 3. List Resources

Click the list buttons to explore:
- **List Tools**: View and execute available tools
- **List Prompts**: View and retrieve prompts
- **List Resources**: View and read resources

### 4. Execute Operations

#### Execute a Tool

1. Click "List Tools"
2. Find a tool and click "Execute"
3. Enter JSON arguments (if required)
4. Click "Execute Tool"
5. View the result in the response area

Example for filesystem-server `read_file` tool:
```json
{
  "path": "/tmp/test.txt"
}
```

#### Read a Resource

1. Click "List Resources"
2. Find a resource and click "Read"
3. Click "Read Resource"
4. View the resource content

#### Get a Prompt

1. Click "List Prompts"
2. Find a prompt and click "Get Prompt"
3. Enter JSON arguments (if required)
4. Click "Get Prompt"
5. View the prompt content

## Configuration

### Custom MCP Servers

You can add your own MCP servers to `.mcp-inspector.json`:

```json
{
  "servers": [
    {
      "name": "my-custom-server",
      "transport": "stdio",
      "command": ["path/to/server"],
      "args": ["arg1", "arg2"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  ]
}
```

### Transport Types

The MCP Inspector supports three transport types:

#### stdio (Command-based)
```json
{
  "name": "my-server",
  "transport": "stdio",
  "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem"],
  "args": ["/tmp"]
}
```

#### SSE (Server-Sent Events)
```json
{
  "name": "my-server",
  "transport": "sse",
  "url": "http://localhost:8080/sse"
}
```

#### WebSocket
```json
{
  "name": "my-server",
  "transport": "websocket",
  "url": "ws://localhost:8080/ws"
}
```

## Testing with Real MCP Servers

### Filesystem Server

The filesystem server allows you to interact with files in a specified directory:

```bash
# List available tools
# Click "List Tools" to see: read_file, write_file, list_directory, etc.

# Read a file
# Execute read_file with: {"path": "/tmp/test.txt"}

# Write a file
# Execute write_file with: {"path": "/tmp/output.txt", "content": "Hello from MCP Inspector!"}
```

### GitHub Server

The GitHub server allows you to interact with GitHub repositories:

```bash
# Set your GitHub token
export GITHUB_TOKEN=ghp_your_token_here

# Start the server and explore:
# - List repositories
# - Search code
# - Get repository contents
# - And more!
```

## Troubleshooting

### "No Servers Configured" Error

Make sure `.mcp-inspector.json` exists in one of these locations:
- `./inspector/.mcp-inspector.json` (project-level)
- `~/.mcp-inspector.json` (user-level)

### Connection Errors

If you see connection errors:

1. **Check MCP Server Installation**:
   ```bash
   npx -y @modelcontextprotocol/server-filesystem /tmp
   ```

2. **Verify Environment Variables**:
   ```bash
   echo $GITHUB_TOKEN
   ```

3. **Check Server Logs**:
   Look at the Rails server output for detailed error messages

### Timeout Errors

Operations timeout after 30 seconds. If you're working with slow servers:
- Check your network connection
- Ensure the MCP server is responding
- Consider increasing the timeout in the controller

## Development

### Structure

```
inspector/
├── app/                    # Rails app files
├── config/
│   ├── application.rb     # Engine loaded here
│   └── routes.rb          # Engine mounted here
├── .mcp-inspector.json    # Sample MCP server configuration
├── Gemfile                # MCP Inspector gem loaded from parent
└── README.md              # This file
```

### Adding Authentication

To add authentication to the MCP Inspector:

```ruby
# config/routes.rb
authenticate :user do
  mount McpInspector::Web::Engine, at: "/mcp_inspector"
end
```

Or use a before_action:

```ruby
# config/initializers/mcp_inspector.rb
McpInspector::Web::ApplicationController.class_eval do
  before_action :authenticate_user!
end
```

### Customizing Views

You can override any view by creating a file with the same path in your app:

```
app/views/mcp_inspector/web/
  ├── dashboard/
  │   └── index.html.erb
  ├── servers/
  │   └── _tools.html.erb
  └── layouts/
      └── mcp_inspector/web/
          └── application.html.erb
```

## Learn More

- [MCP Inspector Web Interface Documentation](../WEB_README.md)
- [MCP Inspector CLI Documentation](../README.md)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)

## Tips

1. **Start with filesystem-server**: It's the easiest to test since it doesn't require API keys
2. **Create test files**: Create some files in `/tmp` to test reading and writing
3. **Explore the JSON responses**: Click on "View Input Schema" to understand tool parameters
4. **Use the browser console**: Check for any JavaScript errors if something doesn't work
5. **Watch the Rails logs**: Server output shows detailed information about each operation

## Example Workflow

Here's a complete example workflow to get started:

```bash
# 1. Create a test file
echo "Hello MCP Inspector" > /tmp/test.txt

# 2. Start the demo app
cd inspector
bundle install
rails db:create db:migrate
rails server

# 3. Open browser to http://localhost:3000

# 4. Select "filesystem-server" from the dropdown

# 5. Click "List Tools" to see available tools

# 6. Find "read_file" and click "Execute"

# 7. Enter arguments: {"path": "/tmp/test.txt"}

# 8. Click "Execute Tool"

# 9. See the file contents in the response area!
```

## Next Steps

- Add your own MCP servers to the configuration
- Customize the UI to match your application's style
- Add authentication and authorization
- Deploy to your production environment
- Integrate with your existing Rails application

## Support

For issues or questions:
- Check the main [MCP Inspector documentation](../README.md)
- Review the [Web Interface documentation](../WEB_README.md)
- Open an issue on GitHub

## License

Same as the main mcp-inspector gem.

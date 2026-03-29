# MCP Inspector Web Interface

The MCP Inspector Web Interface is a Rails Engine that provides a browser-based UI for inspecting and interacting with MCP (Model Context Protocol) servers.

## Features

- 🌐 Web-based interface for MCP server inspection
- 🔄 Real-time updates using Hotwire/Turbo Streams
- 🎨 Modern UI with Tailwind CSS
- 📦 Easy integration into existing Rails applications
- 🔌 Uses existing JSON configuration files (same as CLI)
- ⚡ Interactive tool execution, prompt retrieval, and resource reading

## Installation

Add the gem to your Rails application's Gemfile:

```ruby
gem 'mcp-inspector'
```

Then run:

```bash
bundle install
```

## Setup

### 1. Mount the Engine

In your Rails application's `config/routes.rb`, mount the engine:

```ruby
Rails.application.routes.draw do
  # Mount the MCP Inspector at /mcp_inspector
  mount McpInspector::Web::Engine, at: '/mcp_inspector'

  # Your other routes...
end
```

### 2. Require the Web Engine

In your `config/application.rb` or an initializer, require the web engine:

```ruby
# config/application.rb
require 'mcp_inspector_web'

module YourApp
  class Application < Rails::Application
    # ...
  end
end
```

Or create an initializer:

```ruby
# config/initializers/mcp_inspector.rb
require 'mcp_inspector_web'
```

### 3. Configure MCP Servers

The web interface uses the same configuration files as the CLI. Create or edit `~/.mcp-inspector.json`:

```json
{
  "servers": [
    {
      "name": "filesystem-server",
      "transport": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem"],
      "args": ["/path/to/allowed/directory"],
      "env": {}
    },
    {
      "name": "github-server",
      "transport": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  ],
  "defaults": {
    "output": "json",
    "pretty": true
  }
}
```

You can also use project-level configuration at `./.mcp-inspector.json`.

### 4. Start Your Rails Server

```bash
rails server
```

Visit `http://localhost:3000/mcp_inspector` (or whatever path you mounted it at).

## Usage

### Interface Overview

The MCP Inspector web interface is divided into two main sections:

#### Left Panel: Server Selection & Operations

1. **Select Server**: Choose from configured MCP servers
2. **Server Info**: Get server capabilities and metadata
3. **List Operations**: View available tools, prompts, and resources

#### Right Panel: Response Area

- Displays results from operations
- Shows detailed information about tools, prompts, and resources
- Provides interactive forms for execution

### Available Operations

#### 1. Get Server Info

Click "Get Server Info" to view:
- Server capabilities (tools, resources, prompts support)
- Server metadata (name, version, etc.)
- Raw JSON response

#### 2. List Tools

Click "List Tools" to view all available tools. For each tool, you can:
- View description and input schema
- Click "Execute" to expand the execution form
- Enter JSON arguments
- Execute the tool and see results

Example tool execution:
```json
{
  "path": "/home/user/documents",
  "pattern": "*.txt"
}
```

#### 3. List Prompts

Click "List Prompts" to view all available prompts. For each prompt, you can:
- View description and arguments
- Click "Get Prompt" to expand the form
- Enter JSON arguments
- Retrieve the prompt content

#### 4. List Resources

Click "List Resources" to view all available resources. For each resource, you can:
- View URI, MIME type, and description
- Click "Read" to read the resource content
- View the full resource data

### Real-time Updates

The interface uses Hotwire/Turbo Streams for seamless, real-time updates:
- No full page reloads
- Instant feedback on operations
- Smooth transitions between views

## Customization

### Styling

The web interface uses Tailwind CSS loaded via CDN. To customize the styling:

1. Create a custom stylesheet in your main application
2. Override the default Tailwind classes
3. Or modify the views in your application

### Views

You can override any view by creating a file with the same path in your main application:

```
app/views/mcp_inspector/web/
  ├── dashboard/
  │   └── index.html.erb          # Override main dashboard
  ├── servers/
  │   ├── _tools.html.erb         # Override tools list
  │   ├── _prompts.html.erb       # Override prompts list
  │   └── _resources.html.erb     # Override resources list
  └── layouts/
      └── mcp_inspector/web/
          └── application.html.erb # Override layout
```

### Controllers

You can extend or customize controllers by inheriting from the engine controllers:

```ruby
# app/controllers/mcp_inspector/web/dashboard_controller.rb
module McpInspector
  module Web
    class DashboardController < McpInspector::Web::ApplicationController
      # Add your custom actions or override existing ones
      before_action :authenticate_user! # Example: add authentication

      def index
        super
        # Add custom logic
      end
    end
  end
end
```

## Configuration

### Custom Config Paths

By default, the engine looks for configuration in:
1. `./.mcp-inspector.json` (project-level)
2. `~/.mcp-inspector.json` (user-level)

You can customize this behavior by creating an initializer:

```ruby
# config/initializers/mcp_inspector.rb
McpInspector::Web::Engine.config.before_initialize do
  # Custom configuration logic
end
```

### Timeout Settings

Server operations have a 30-second timeout by default. This is configured in the controllers:

```ruby
# lib/mcp_inspector/web/app/controllers/mcp_inspector/web/servers_controller.rb
Timeout.timeout(30) do
  # Server operation
end
```

You can customize this by overriding the controller.

## Security Considerations

⚠️ **Important Security Notes:**

1. **Authentication**: The engine does not include authentication by default. Add authentication in your main application:

```ruby
# config/routes.rb
authenticate :user do
  mount McpInspector::Web::Engine, at: '/mcp_inspector'
end
```

2. **Authorization**: Consider restricting access to admin users only
3. **CSRF Protection**: Enabled by default through Rails
4. **Server Access**: Only configured MCP servers can be accessed
5. **Input Validation**: JSON arguments are validated before execution

## Troubleshooting

### Server Connection Errors

If you see connection errors:
1. Check your MCP server configuration
2. Ensure the MCP server is installed and accessible
3. Verify environment variables are set correctly
4. Check server logs for detailed error messages

### Configuration Not Found

If you see "Configuration Error":
1. Create `~/.mcp-inspector.json` with server configurations
2. Ensure the JSON is valid
3. Check file permissions

### Turbo/JavaScript Issues

If interactions don't work:
1. Ensure Turbo is loaded (check browser console)
2. Verify Rails UJS is properly configured
3. Check for JavaScript errors in browser console

## Demo Application

A fully configured demo application is included in the `inspector/` directory:

```bash
cd inspector
bin/start
# Visit http://localhost:3000
```

The demo app includes:
- Pre-configured MCP servers (filesystem and GitHub)
- Sample `.mcp-inspector.json` configuration
- Complete integration example
- Comprehensive README with usage guide

See [inspector/README.md](inspector/README.md) for details.

## Development

### Running Tests

```bash
bundle exec rspec
```

### Local Development

The easiest way to test the web interface is to use the included demo app (see above).

Alternatively, create your own Rails app:

1. Create a new Rails app:
```bash
rails new test_app
cd test_app
```

2. Add to Gemfile:
```ruby
gem 'mcp-inspector', path: '/path/to/mcp-inspector'
```

3. Mount the engine and test

## Architecture

The web interface follows Rails Engine conventions:

```
lib/mcp_inspector/web/
├── engine.rb                                    # Engine definition
├── config/
│   └── routes.rb                               # Engine routes
└── app/
    ├── controllers/
    │   └── mcp_inspector/web/
    │       ├── application_controller.rb       # Base controller
    │       ├── dashboard_controller.rb         # Main dashboard
    │       ├── servers_controller.rb           # Server operations
    │       └── operations_controller.rb        # Tool/prompt/resource execution
    └── views/
        └── mcp_inspector/web/
            ├── layouts/
            │   └── application.html.erb        # Layout with Tailwind
            ├── dashboard/
            │   └── index.html.erb              # Main interface
            ├── servers/
            │   ├── _info.html.erb              # Server info partial
            │   ├── _tools.html.erb             # Tools list partial
            │   ├── _prompts.html.erb           # Prompts list partial
            │   ├── _resources.html.erb         # Resources list partial
            │   └── *.turbo_stream.erb          # Turbo Stream responses
            ├── operations/
            │   ├── _result.html.erb            # Operation result partial
            │   └── result.turbo_stream.erb     # Turbo Stream response
            └── shared/
                └── _error.html.erb             # Error partial
```

### Data Flow

1. User selects a server and clicks an operation button
2. JavaScript makes a fetch request to the appropriate controller action
3. Controller connects to MCP server using existing `ClientAdapter`
4. Response is rendered as a Turbo Stream
5. Turbo Stream updates the response area without page reload

### Reusing CLI Infrastructure

The web interface reuses the existing CLI infrastructure:
- `McpInspector::Data::ConfigManager` - Configuration loading
- `McpInspector::Transport::ClientAdapter` - Server connections
- `McpInspector::Transport::ServerConfig` - Server configuration
- All error handling and validation

## Contributing

Contributions are welcome! Please submit pull requests or issues on GitHub.

## License

Same as the main mcp-inspector gem.

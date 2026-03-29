# Naming Convention Change

## Summary

The gem has been renamed from `MCPInspector` to `McpInspector` to follow Ruby naming conventions and avoid complex inflection configuration.

## Why the Change?

Ruby/Rails conventions dictate that:
- Acronyms should only stay fully uppercase when standalone (e.g., `MCP`) or at the end of a constant name (e.g., `ServerMCP`)
- In compound names, only the first letter of each word should be capitalized (e.g., `HttpClient`, not `HTTPClient`)
- `McpInspector` follows this convention, treating "Mcp" as a word rather than requiring special inflection rules

This change:
✅ Simplifies autoloading (no custom Zeitwerk inflections needed)
✅ Follows Rails conventions
✅ Avoids conflicts between gem and Rails autoloaders
✅ Makes the codebase more maintainable

## What Changed

### Module Names
- `MCPInspector` → `McpInspector`
- `MCPInspector::Web` → `McpInspector::Web`
- All nested modules updated accordingly

### File Changes

**Core Library:**
- `lib/mcp_inspector.rb` - Removed inflection config
- `lib/mcp_inspector/version.rb` - Updated module name
- `lib/mcp_inspector/cli.rb` - Updated all class references
- All files in `lib/mcp_inspector/transport/` - Updated module names
- All files in `lib/mcp_inspector/data/` - Updated module names
- All files in `lib/mcp_inspector/presentation/` - Updated module names

**Web Engine:**
- `lib/mcp_inspector_web.rb` - Updated module name
- `lib/mcp_inspector/web/engine.rb` - Removed inflection initializer
- `lib/mcp_inspector/web/config/routes.rb` - Updated engine reference
- All controllers - Updated module names
- All views - Updated references (if any)

**Demo Application:**
- `inspector/config/routes.rb` - Updated mount statement
- `inspector/config/initializers/inflections.rb` - Removed MCP acronym
- `inspector/config/application.rb` - No changes needed (require still works)

**Documentation:**
- `README.md` - Updated all code examples
- `WEB_README.md` - Removed inflection step, updated examples
- `inspector/README.md` - Removed inflection section
- `QUICKSTART.md` - Removed inflection step
- `mcp-inspector.gemspec` - Updated version constant reference

## Usage Examples

### Before (with inflections)

```ruby
# Needed inflection configuration
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "MCP"
end

# Module reference
module MCPInspector
  module Web
    # ...
  end
end

# Mount statement
mount MCPInspector::Web::Engine, at: '/mcp_inspector'
```

### After (no inflections needed)

```ruby
# No inflection configuration needed!

# Module reference
module McpInspector
  module Web
    # ...
  end
end

# Mount statement
mount McpInspector::Web::Engine, at: '/mcp_inspector'
```

## Migration Guide

If you have an existing installation:

1. **Update your routes** (`config/routes.rb`):
   ```ruby
   # Old
   mount MCPInspector::Web::Engine, at: '/mcp_inspector'

   # New
   mount McpInspector::Web::Engine, at: '/mcp_inspector'
   ```

2. **Remove inflection configuration** (`config/initializers/inflections.rb`):
   ```ruby
   # Remove this:
   ActiveSupport::Inflector.inflections(:en) do |inflect|
     inflect.acronym "MCP"
   end
   ```

3. **Update any custom code** that references the modules:
   ```ruby
   # Old
   MCPInspector::Data::ConfigManager

   # New
   McpInspector::Data::ConfigManager
   ```

4. **Restart your server**

That's it! No changes needed to configuration files or other aspects of the gem.

## Benefits

- ✅ **Simpler setup** - No inflection configuration required
- ✅ **Standard Rails** - Follows Rails autoloading conventions
- ✅ **Less magic** - No custom Zeitwerk configuration
- ✅ **More maintainable** - Easier for other developers to understand
- ✅ **Fewer conflicts** - Avoids autoloader conflicts

## Technical Details

The change affects:
- **14 Ruby files** in `lib/mcp_inspector/`
- **4 controller files** in the web engine
- **1 routes file** in the web engine
- **1 engine file**
- **4 documentation files**
- **Demo app configuration**

All references to `MCPInspector` have been systematically replaced with `McpInspector` throughout the codebase.

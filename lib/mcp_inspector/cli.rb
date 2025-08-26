# frozen_string_literal: true

require "thor"
require_relative "data/config_manager"
require_relative "data/input_adapter"
require_relative "data/output_adapter"
require_relative "transport/base_adapter"
require_relative "transport/client_adapter"
require_relative "transport/server_config"
require_relative "presentation/base_formatter"
require_relative "presentation/json_formatter"

module MCPInspector
  class CLI < Thor
    class << self
      def exit_on_failure?
        true
      end
    end

    class_option :config, type: :string, desc: "Path to config file"
    class_option :server, type: :string, desc: "Server name from config"
    class_option :output, type: :string, default: "json", desc: "Output format (json)"
    class_option :pretty, type: :boolean, default: true, desc: "Pretty print output"
    class_option :no_pretty, type: :boolean, desc: "Disable pretty printing"

    def initialize(args = [], local_options = {}, config = {})
      super
      setup_global_options
    end

    desc "list TYPE", "List MCP server resources (tools, resources, prompts)"
    def list(type)
      case type
      when "tools"
        list_tools
      when "resources"
        list_resources
      when "prompts"
        list_prompts
      else
        warn "Invalid list type '#{type}'. Valid options: tools, resources, prompts"
        exit(1)
      end
    end

    desc "execute TOOL_NAME", "Execute a tool on the MCP server"
    option :args, type: :string, desc: "JSON arguments for the tool", default: "{}"
    def execute(tool_name)
      with_server_connection do |adapter, output_adapter|
        input_adapter = MCPInspector::Data::InputAdapter.new
        input_adapter.validate_tool_name!(tool_name)
        
        arguments = input_adapter.parse_json_arguments(options[:args])
        result = adapter.execute_tool(tool_name, arguments)
        
        metadata = build_metadata("execute_tool", tool_name)
        output_adapter.output_tool_result(result, metadata)
      end
    rescue => e
      handle_error(e)
    end

    desc "read RESOURCE_URI", "Read a resource from the MCP server"
    def read(resource_uri)
      with_server_connection do |adapter, output_adapter|
        input_adapter = MCPInspector::Data::InputAdapter.new
        input_adapter.validate_resource_uri!(resource_uri)
        
        content = adapter.read_resource(resource_uri)
        
        metadata = build_metadata("read_resource", resource_uri)
        output_adapter.output_resource_content(content, metadata)
      end
    rescue => e
      handle_error(e)
    end

    desc "prompt PROMPT_NAME", "Get a prompt from the MCP server"
    option :args, type: :string, desc: "JSON arguments for the prompt", default: "{}"
    def prompt(prompt_name)
      with_server_connection do |adapter, output_adapter|
        input_adapter = MCPInspector::Data::InputAdapter.new
        input_adapter.validate_prompt_name!(prompt_name)
        
        arguments = input_adapter.parse_json_arguments(options[:args])
        result = adapter.get_prompt(prompt_name, arguments)
        
        metadata = build_metadata("get_prompt", prompt_name)
        output_adapter.output_prompt_result(result, metadata)
      end
    rescue => e
      handle_error(e)
    end

    desc "info", "Show server connection details and capabilities"
    def info
      with_server_connection do |adapter, output_adapter|
        server_info = adapter.server_info
        
        metadata = build_metadata("server_info")
        output_adapter.output_server_info(server_info, metadata)
      end
    rescue => e
      handle_error(e)
    end

    desc "config ACTION [NAME]", "Manage configuration (list, show SERVER_NAME, init [PATH])"
    def config(action, name_or_path = nil)
      case action
      when "list"
        config_list
      when "show"
        config_show(name_or_path)
      when "init"
        config_init(name_or_path)
      else
        warn "Invalid config action '#{action}'. Valid options: list, show, init"
        exit(1)
      end
    end

    private

    def setup_global_options
      # Handle --no-pretty flag
      if options[:no_pretty]
        @pretty_print = false
      else
        @pretty_print = options.fetch(:pretty, true)
      end
    end

    def with_server_connection
      ensure_server_specified!
      config_manager = load_config_manager
      server_config = config_manager.find_server(options[:server])
      
      adapter = MCPInspector::Transport::ClientAdapter.new
      output_adapter = create_output_adapter
      
      begin
        adapter.connect(server_config)
        yield adapter, output_adapter
      ensure
        adapter.disconnect if adapter.connected?
      end
    end

    def load_config_manager
      MCPInspector::Data::ConfigManager.new(config_path: options[:config])
    rescue MCPInspector::Data::ConfigManager::ConfigError => e
      if e.message.include?("No configuration file found")
        suggest_config_creation
      end
      raise
    end

    def suggest_config_creation
      warn "Tip: Create a configuration file with:"
      warn "  mcp-inspector config init"
    end

    def create_output_adapter
      MCPInspector::Data::OutputAdapter.new(
        format: options[:output],
        pretty: @pretty_print
      )
    end

    def build_metadata(operation, target = nil)
      metadata = {
        operation: operation,
        server: options[:server]
      }
      
      metadata[:target] = target if target
      metadata
    end

    def handle_error(error)
      output_adapter = create_output_adapter
      metadata = build_metadata("error")
      output_adapter.output_error(error, metadata)
      exit(1)
    end

    def ensure_server_specified!
      unless options[:server]
        warn "Error: --server option is required for this command"
        exit(1)
      end
    end

    def list_tools
      with_server_connection do |adapter, output_adapter|
        tools = adapter.list_tools
        
        metadata = build_metadata("list_tools")
        output_adapter.output_tools_list(tools, metadata)
      end
    end

    def list_resources
      with_server_connection do |adapter, output_adapter|
        resources = adapter.list_resources
        
        metadata = build_metadata("list_resources")
        output_adapter.output_resources_list(resources, metadata)
      end
    end

    def list_prompts
      with_server_connection do |adapter, output_adapter|
        prompts = adapter.list_prompts
        
        metadata = build_metadata("list_prompts")
        output_adapter.output_prompts_list(prompts, metadata)
      end
    end

    def config_list
      config_manager = load_config_manager
      output_adapter = create_output_adapter
      
      metadata = build_metadata("config_list")
      output_adapter.output_config_list(config_manager.servers, metadata)
    end

    def config_show(server_name)
      unless server_name
        warn "Server name is required for 'config show'"
        exit(1)
      end
      
      config_manager = load_config_manager
      server_config = config_manager.find_server(server_name)
      output_adapter = create_output_adapter
      
      metadata = build_metadata("config_show", server_name)
      output_adapter.output_config_details(server_config, metadata)
    end

    def config_init(path = nil)
      path ||= MCPInspector::Data::ConfigManager::DEFAULT_USER_CONFIG_PATH
      
      if File.exist?(path)
        warn "Configuration file already exists: #{path}"
        exit(1)
      end
      
      created_path = MCPInspector::Data::ConfigManager.create_example_config(path)
      puts "Created example configuration file: #{created_path}"
      puts "Edit this file to configure your MCP servers."
    end
  end
end
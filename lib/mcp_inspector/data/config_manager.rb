# frozen_string_literal: true

require "json"
require "pathname"
require "fileutils"

module MCPInspector
  module Data
    class ConfigManager
      class ConfigError < Error; end

      DEFAULT_USER_CONFIG_PATH = File.expand_path("~/.mcp-inspector.json")
      DEFAULT_PROJECT_CONFIG_PATH = "./.mcp-inspector.json"

      def initialize(config_path: nil)
        @config_path = config_path
        @config = load_merged_config
        validate_config!
      end

      def servers
        @servers ||= build_server_configs
      end

      def server_names
        servers.keys
      end

      def find_server(name)
        servers[name] or raise ConfigError, "Server '#{name}' not found"
      end

      def defaults
        @config["defaults"] || {}
      end

      def output_format
        defaults["output"] || "json"
      end

      def pretty_print?
        defaults.fetch("pretty", true)
      end

      def to_h
        @config
      end

      def self.config_file_exists?(path = nil)
        paths_to_check = if path
                          [path]
                        else
                          [DEFAULT_PROJECT_CONFIG_PATH, DEFAULT_USER_CONFIG_PATH]
                        end

        paths_to_check.any? { |p| File.exist?(p) }
      end

      def self.create_example_config(path = DEFAULT_USER_CONFIG_PATH)
        example_config = {
          "servers" => [
            {
              "name" => "filesystem-server",
              "transport" => "stdio",
              "command" => ["npx", "-y", "@modelcontextprotocol/server-filesystem"],
              "args" => ["/tmp"],
              "env" => {}
            },
            {
              "name" => "github-server",
              "transport" => "stdio", 
              "command" => ["npx", "-y", "@modelcontextprotocol/server-github"],
              "env" => {
                "GITHUB_TOKEN" => "${GITHUB_TOKEN}"
              }
            }
          ],
          "defaults" => {
            "output" => "json",
            "pretty" => true
          }
        }

        File.write(path, JSON.pretty_generate(example_config))
        path
      end

      private

      attr_reader :config_path

      def load_merged_config
        configs = []

        # Load in order of precedence (last wins)
        configs << load_user_config if user_config_exists?
        configs << load_project_config if project_config_exists?
        configs << load_custom_config if custom_config_specified?

        if configs.empty?
          # Auto-create default config file like Claude Desktop does
          created_config_path = auto_create_default_config
          raise ConfigError, build_no_config_error_message(created_config_path)
        end

        merge_configs(configs)
      end

      def load_user_config
        load_config_file(DEFAULT_USER_CONFIG_PATH)
      end

      def load_project_config
        load_config_file(DEFAULT_PROJECT_CONFIG_PATH)
      end

      def load_custom_config
        load_config_file(config_path)
      end

      def load_config_file(path)
        content = File.read(path)
        JSON.parse(content)
      rescue JSON::ParserError => e
        raise ConfigError, "Invalid JSON in config file '#{path}': #{e.message}"
      rescue Errno::ENOENT
        raise ConfigError, "Configuration file not found: #{path}"
      rescue Errno::EACCES
        raise ConfigError, "Configuration file not readable: #{path}"
      end

      def merge_configs(configs)
        base_config = { "servers" => [], "defaults" => {} }
        
        configs.each do |config|
          base_config = deep_merge(base_config, config)
        end

        base_config
      end

      def deep_merge(hash1, hash2)
        result = hash1.dup
        
        hash2.each do |key, value|
          if result[key].is_a?(Hash) && value.is_a?(Hash)
            result[key] = deep_merge(result[key], value)
          elsif key == "servers" && result[key].is_a?(Array) && value.is_a?(Array)
            result[key] = merge_servers(result[key], value)
          else
            result[key] = value
          end
        end

        result
      end

      def merge_servers(servers1, servers2)
        merged = servers1.dup
        servers2.each do |server|
          existing_index = merged.find_index { |s| s["name"] == server["name"] }
          if existing_index
            merged[existing_index] = server
          else
            merged << server
          end
        end
        merged
      end

      def validate_config!
        raise ConfigError, "Configuration must be a hash" unless @config.is_a?(Hash)
        raise ConfigError, "No 'servers' section found in configuration" unless @config["servers"]
        raise ConfigError, "'servers' must be an array" unless @config["servers"].is_a?(Array)
        raise ConfigError, "No servers configured" if @config["servers"].empty?
      end

      def build_server_configs
        server_configs = {}
        
        @config["servers"].each do |server_hash|
          begin
            server_config = MCPInspector::Transport::ServerConfig.new(server_hash)
            server_configs[server_config.name] = server_config
          rescue MCPInspector::Transport::ServerConfig::ValidationError => e
            raise ConfigError, "Invalid server configuration: #{e.message}"
          end
        end

        server_configs
      end

      def user_config_exists?
        File.exist?(DEFAULT_USER_CONFIG_PATH)
      end

      def project_config_exists?
        File.exist?(DEFAULT_PROJECT_CONFIG_PATH)
      end

      def custom_config_specified?
        config_path && File.exist?(config_path)
      end

      def auto_create_default_config
        # Determine where to create the config file
        config_file_path = config_path || DEFAULT_USER_CONFIG_PATH
        
        # Ensure the parent directory exists
        parent_dir = File.dirname(config_file_path)
        FileUtils.mkdir_p(parent_dir) unless File.directory?(parent_dir)
        
        # Create the config file with example servers
        self.class.create_example_config(config_file_path)
        
        config_file_path
      end

      def build_no_config_error_message(created_config_path)
        <<~ERROR
          No configuration file found, so I created one for you at:
            #{created_config_path}

          This file contains example MCP server configurations. Please edit it to:
          1. Add your actual MCP servers
          2. Remove or modify the example servers as needed
          3. Set any custom defaults

          Then run your command again.

          Example servers included:
          - filesystem-server: For file system operations
          - github-server: For GitHub operations (requires GITHUB_TOKEN)
        ERROR
      end
    end
  end
end
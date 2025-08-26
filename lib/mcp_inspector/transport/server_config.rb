# frozen_string_literal: true

require "json"

module MCPInspector
  module Transport
    class ServerConfig
      class ValidationError < Error; end

      REQUIRED_FIELDS = %w[name transport].freeze
      STDIO_REQUIRED_FIELDS = %w[command].freeze
      URL_REQUIRED_FIELDS = %w[url].freeze
      VALID_TRANSPORTS = %w[stdio sse websocket].freeze

      attr_reader :name, :transport, :command, :args, :env, :working_directory, :url

      def initialize(config_hash)
        @raw_config = config_hash
        validate_and_parse_config!
      end

      def self.from_json(json_string)
        config_hash = JSON.parse(json_string)
        new(config_hash)
      rescue JSON::ParserError => e
        raise ValidationError, "Invalid JSON: #{e.message}"
      end

      def stdio?
        transport == "stdio"
      end

      def sse?
        transport == "sse"
      end

      def websocket?
        transport == "websocket"
      end

      def to_h
        {
          name: name,
          transport: transport,
          command: command,
          args: args,
          env: env,
          working_directory: working_directory,
          url: url
        }.compact
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      private

      attr_reader :raw_config

      def validate_and_parse_config!
        validate_required_fields!
        validate_transport!
        validate_transport_specific_fields!
        parse_fields!
      end

      def validate_required_fields!
        missing_fields = REQUIRED_FIELDS - raw_config.keys
        return if missing_fields.empty?

        raise ValidationError, "Missing required fields: #{missing_fields.join(', ')}"
      end

      def validate_transport!
        unless VALID_TRANSPORTS.include?(raw_config["transport"])
          raise ValidationError, "Invalid transport '#{raw_config['transport']}'. Valid options: #{VALID_TRANSPORTS.join(', ')}"
        end
      end

      def validate_transport_specific_fields!
        case raw_config["transport"]
        when "stdio"
          validate_stdio_fields!
        when "sse", "websocket"
          validate_url_fields!
        end
      end

      def validate_stdio_fields!
        missing_fields = STDIO_REQUIRED_FIELDS - raw_config.keys
        return if missing_fields.empty?

        raise ValidationError, "Missing required fields for stdio transport: #{missing_fields.join(', ')}"
      end

      def validate_url_fields!
        missing_fields = URL_REQUIRED_FIELDS - raw_config.keys
        return if missing_fields.empty?

        raise ValidationError, "Missing required fields for URL-based transport: #{missing_fields.join(', ')}"
      end

      def parse_fields!
        @name = raw_config["name"]
        @transport = raw_config["transport"]
        @command = parse_command(raw_config["command"]) if raw_config["command"]
        @args = raw_config["args"] || []
        @env = parse_env(raw_config["env"] || {})
        @working_directory = raw_config["working_directory"] || "."
        @url = raw_config["url"] if raw_config["url"]
      end

      def parse_command(command)
        case command
        when Array
          command
        when String
          command.split
        else
          raise ValidationError, "Command must be a string or array of strings"
        end
      end

      def parse_env(env_hash)
        return {} unless env_hash.is_a?(Hash)

        env_hash.transform_values { |value| expand_env_variable(value) }
      end

      def expand_env_variable(value)
        return value unless value.is_a?(String)

        value.gsub(/\$\{([^}]+)\}/) do |match|
          env_var = ::Regexp.last_match(1)
          ENV[env_var] || match
        end
      end
    end
  end
end
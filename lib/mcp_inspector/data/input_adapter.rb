# frozen_string_literal: true

require "json"

module MCPInspector
  module Data
    class InputAdapter
      class ValidationError < Error; end

      def initialize(args = [], options = {})
        @args = args
        @options = options
      end

      def parse_json_arguments(json_string)
        return {} if json_string.nil? || json_string.empty?

        JSON.parse(json_string)
      rescue JSON::ParserError => e
        raise ValidationError, "Invalid JSON arguments: #{e.message}\nExpected format: '{\"key\": \"value\"}'"
      end

      def validate_server_name!(server_name, available_servers)
        return if available_servers.include?(server_name)

        if available_servers.empty?
          raise ValidationError, "No servers configured. Please add servers to your configuration file."
        else
          raise ValidationError, "Server '#{server_name}' not found. Available servers: #{available_servers.join(', ')}"
        end
      end

      def validate_tool_name!(tool_name)
        raise ValidationError, "Tool name is required" if tool_name.nil? || tool_name.empty?
      end

      def validate_resource_uri!(uri)
        raise ValidationError, "Resource URI is required" if uri.nil? || uri.empty?
      end

      def validate_prompt_name!(prompt_name)
        raise ValidationError, "Prompt name is required" if prompt_name.nil? || prompt_name.empty?
      end

      def validate_config_file!(config_path)
        unless File.exist?(config_path)
          raise ValidationError, "Configuration file not found: #{config_path}"
        end

        unless File.readable?(config_path)
          raise ValidationError, "Configuration file is not readable: #{config_path}"
        end
      end

      def transform_to_operation_params(command, subcommand = nil, *args)
        {
          command: command,
          subcommand: subcommand,
          target: args.first,
          arguments: parse_json_arguments(@options[:args])
        }.compact
      end

      private

      attr_reader :args, :options
    end
  end
end
# frozen_string_literal: true

module MCPInspector
  module Data
    class OutputAdapter
      DEFAULT_FORMAT = "json"
      VALID_FORMATS = %w[json terminal].freeze

      def initialize(format: DEFAULT_FORMAT, pretty: true, output_destination: $stdout)
        @format = validate_format(format)
        @pretty = pretty
        @output_destination = output_destination
        @formatter = create_formatter
      end

      def output_success(data, metadata = {})
        formatted_output = @formatter.format_success(data, metadata)
        write_output(formatted_output)
      end

      def output_error(error, metadata = {})
        formatted_output = @formatter.format_error(error, metadata)
        write_output(formatted_output)
      end

      def output_tools_list(tools, metadata = {})
        formatted_output = @formatter.format_tools_list(tools, metadata)
        write_output(formatted_output)
      end

      def output_resources_list(resources, metadata = {})
        formatted_output = @formatter.format_resources_list(resources, metadata)
        write_output(formatted_output)
      end

      def output_prompts_list(prompts, metadata = {})
        formatted_output = @formatter.format_prompts_list(prompts, metadata)
        write_output(formatted_output)
      end

      def output_tool_result(result, metadata = {})
        formatted_output = @formatter.format_tool_result(result, metadata)
        write_output(formatted_output)
      end

      def output_resource_content(content, metadata = {})
        formatted_output = @formatter.format_resource_content(content, metadata)
        write_output(formatted_output)
      end

      def output_prompt_result(result, metadata = {})
        formatted_output = @formatter.format_prompt_result(result, metadata)
        write_output(formatted_output)
      end

      def output_server_info(info, metadata = {})
        formatted_output = @formatter.format_server_info(info, metadata)
        write_output(formatted_output)
      end

      def output_config_list(servers, metadata = {})
        formatted_output = @formatter.format_config_list(servers, metadata)
        write_output(formatted_output)
      end

      def output_config_details(server_config, metadata = {})
        formatted_output = @formatter.format_config_details(server_config, metadata)
        write_output(formatted_output)
      end

      private

      attr_reader :format, :pretty, :output_destination, :formatter

      def validate_format(format)
        unless VALID_FORMATS.include?(format)
          raise ArgumentError, "Invalid output format '#{format}'. Valid options: #{VALID_FORMATS.join(', ')}"
        end
        format
      end

      def create_formatter
        case format
        when "json"
          MCPInspector::Presentation::JSONFormatter.new(pretty: pretty)
        when "terminal"
          # Placeholder for future terminal formatter
          MCPInspector::Presentation::JSONFormatter.new(pretty: pretty)
        else
          raise ArgumentError, "Unsupported formatter: #{format}"
        end
      end

      def write_output(formatted_output)
        output_destination.puts(formatted_output)
        output_destination.flush if output_destination.respond_to?(:flush)
      end

      def build_metadata(operation:, server: nil, **additional)
        base_metadata = {
          operation: operation,
          timestamp: Time.now.iso8601
        }
        
        base_metadata[:server] = server if server
        base_metadata.merge(additional)
      end
    end
  end
end
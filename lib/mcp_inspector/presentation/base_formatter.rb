# frozen_string_literal: true

module MCPInspector
  module Presentation
    class BaseFormatter
      def initialize(pretty: true)
        @pretty = pretty
      end

      def format_success(data, metadata = {})
        raise NotImplementedError, "Subclasses must implement #format_success"
      end

      def format_error(error, metadata = {})
        raise NotImplementedError, "Subclasses must implement #format_error"
      end

      def format_tools_list(tools, metadata = {})
        raise NotImplementedError, "Subclasses must implement #format_tools_list"
      end

      def format_resources_list(resources, metadata = {})
        raise NotImplementedError, "Subclasses must implement #format_resources_list"
      end

      def format_prompts_list(prompts, metadata = {})
        raise NotImplementedError, "Subclasses must implement #format_prompts_list"
      end

      def format_tool_result(result, metadata = {})
        raise NotImplementedError, "Subclasses must implement #format_tool_result"
      end

      def format_resource_content(content, metadata = {})
        raise NotImplementedError, "Subclasses must implement #format_resource_content"
      end

      def format_prompt_result(result, metadata = {})
        raise NotImplementedError, "Subclasses must implement #format_prompt_result"
      end

      def format_server_info(info, metadata = {})
        raise NotImplementedError, "Subclasses must implement #format_server_info"
      end

      def format_config_list(servers, metadata = {})
        raise NotImplementedError, "Subclasses must implement #format_config_list"
      end

      def format_config_details(server_config, metadata = {})
        raise NotImplementedError, "Subclasses must implement #format_config_details"
      end

      protected

      attr_reader :pretty

      def build_response(status:, data: nil, error: nil, metadata: {})
        response = {
          status: status,
          metadata: build_metadata(metadata)
        }
        
        response[:data] = data if data
        response[:error] = format_error_message(error) if error
        
        response
      end

      def build_metadata(metadata)
        base_metadata = {
          timestamp: Time.now.iso8601
        }
        
        base_metadata.merge(metadata.compact)
      end

      def format_error_message(error)
        case error
        when String
          error
        when StandardError
          {
            type: error.class.name,
            message: error.message
          }
        else
          error.to_s
        end
      end
    end
  end
end
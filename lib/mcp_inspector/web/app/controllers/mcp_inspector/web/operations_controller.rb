# frozen_string_literal: true

module McpInspector
  module Web
    class OperationsController < ApplicationController
      def execute_tool
        server_name = params[:server_name]
        tool_name = params[:tool_name]
        arguments = parse_arguments(params[:arguments])

        server_config = config_manager.servers[server_name]

        connect_to_server(server_config) do |client|
          @result = client.execute_tool(tool_name, arguments)
          @operation_type = "Tool Execution"
          @operation_name = tool_name

          # Debug logging
          Rails.logger.info "=" * 80
          Rails.logger.info "Tool Execution Result:"
          Rails.logger.info "Result class: #{@result.class}"
          Rails.logger.info "Result: #{@result.inspect}"
          Rails.logger.info "=" * 80

          respond_to do |format|
            format.turbo_stream { render "mcp_inspector/web/operations/result" }
            format.html do
              render partial: "mcp_inspector/web/operations/result",
                     locals: { result: @result, operation_type: @operation_type, operation_name: @operation_name }
            end
          end
        end
      end

      def read_resource
        server_name = params[:server_name]
        resource_uri = params[:resource_uri]

        server_config = config_manager.servers[server_name]

        connect_to_server(server_config) do |client|
          @result = client.read_resource(resource_uri)
          @operation_type = "Resource Read"
          @operation_name = resource_uri

          respond_to do |format|
            format.turbo_stream { render "mcp_inspector/web/operations/result" }
            format.html do
              render partial: "mcp_inspector/web/operations/result",
                     locals: { result: @result, operation_type: @operation_type, operation_name: @operation_name }
            end
          end
        end
      end

      def get_prompt
        server_name = params[:server_name]
        prompt_name = params[:prompt_name]
        arguments = parse_arguments(params[:arguments])

        server_config = config_manager.servers[server_name]

        connect_to_server(server_config) do |client|
          @result = client.get_prompt(prompt_name, arguments)
          @operation_type = "Prompt Retrieval"
          @operation_name = prompt_name

          respond_to do |format|
            format.turbo_stream { render "mcp_inspector/web/operations/result" }
            format.html do
              render partial: "mcp_inspector/web/operations/result",
                     locals: { result: @result, operation_type: @operation_type, operation_name: @operation_name }
            end
          end
        end
      end

      private

      def parse_arguments(args_string)
        return {} if args_string.blank?

        JSON.parse(args_string)
      rescue JSON::ParserError => e
        raise McpInspector::Data::InputAdapter::ValidationError, "Invalid JSON arguments: #{e.message}"
      end

      def connect_to_server(server_config)
        McpInspector::Web::Engine.connection_pool.with_connection(server_config) do |client|
          yield client
        end
      rescue McpInspector::Error, Timeout::Error, JSON::ParserError => e
        handle_mcp_error(e)
      end
    end
  end
end

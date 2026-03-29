# frozen_string_literal: true

module McpInspector
  module Web
    class ServersController < ApplicationController
      before_action :load_server_config

      def index
        @servers = config_manager.servers
      end

      def info
        connect_to_server do |client|
          @info = client.server_info
          respond_to do |format|
            format.turbo_stream
            format.html { render partial: "mcp_inspector/web/servers/info", locals: { info: @info } }
          end
        end
      end

      def tools
        connect_to_server do |client|
          @tools = client.list_tools
          respond_to do |format|
            format.turbo_stream
            format.html { render partial: "mcp_inspector/web/servers/tools", locals: { tools: @tools, server_name: params[:id] } }
          end
        end
      end

      def prompts
        connect_to_server do |client|
          @prompts = client.list_prompts
          respond_to do |format|
            format.turbo_stream
            format.html { render partial: "mcp_inspector/web/servers/prompts", locals: { prompts: @prompts, server_name: params[:id] } }
          end
        end
      end

      def resources
        connect_to_server do |client|
          @resources = client.list_resources
          respond_to do |format|
            format.turbo_stream
            format.html { render partial: "mcp_inspector/web/servers/resources", locals: { resources: @resources, server_name: params[:id] } }
          end
        end
      end

      private

      def load_server_config
        @server_name = params[:id]
        @server_config = config_manager.servers[@server_name]

        unless @server_config
          render turbo_stream: turbo_stream.update("response_area",
            partial: "mcp_inspector/web/shared/error",
            locals: { error: "Server '#{@server_name}' not found in configuration" }
          )
          return
        end
      end

      def connect_to_server
        McpInspector::Web::Engine.connection_pool.with_connection(@server_config) do |client|
          yield client
        end
      rescue McpInspector::Error, Timeout::Error => e
        handle_mcp_error(e)
      end
    end
  end
end

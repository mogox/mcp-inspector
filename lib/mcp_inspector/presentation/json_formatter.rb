# frozen_string_literal: true

require "json"

module MCPInspector
  module Presentation
    class JSONFormatter < BaseFormatter
      def format_success(data, metadata = {})
        response = build_response(status: "success", data: data, metadata: metadata)
        to_json(response)
      end

      def format_error(error, metadata = {})
        response = build_response(status: "error", error: error, metadata: metadata)
        to_json(response)
      end

      def format_tools_list(tools, metadata = {})
        data = {
          tools: normalize_list_data(tools),
          count: Array(tools).length
        }
        
        metadata = metadata.merge(operation: "list_tools")
        format_success(data, metadata)
      end

      def format_resources_list(resources, metadata = {})
        data = {
          resources: normalize_list_data(resources),
          count: Array(resources).length
        }
        
        metadata = metadata.merge(operation: "list_resources")
        format_success(data, metadata)
      end

      def format_prompts_list(prompts, metadata = {})
        data = {
          prompts: normalize_list_data(prompts),
          count: Array(prompts).length
        }
        
        metadata = metadata.merge(operation: "list_prompts")
        format_success(data, metadata)
      end

      def format_tool_result(result, metadata = {})
        data = {
          result: result
        }
        
        metadata = metadata.merge(operation: "execute_tool")
        format_success(data, metadata)
      end

      def format_resource_content(content, metadata = {})
        data = {
          content: content
        }
        
        metadata = metadata.merge(operation: "read_resource")
        format_success(data, metadata)
      end

      def format_prompt_result(result, metadata = {})
        data = {
          result: result
        }
        
        metadata = metadata.merge(operation: "get_prompt")
        format_success(data, metadata)
      end

      def format_server_info(info, metadata = {})
        data = {
          server_info: info
        }
        
        metadata = metadata.merge(operation: "server_info")
        format_success(data, metadata)
      end

      def format_config_list(servers, metadata = {})
        server_list = servers.map do |name, config|
          {
            name: name,
            transport: config.transport,
            description: build_server_description(config)
          }
        end
        
        data = {
          servers: server_list,
          count: servers.length
        }
        
        metadata = metadata.merge(operation: "config_list")
        format_success(data, metadata)
      end

      def format_config_details(server_config, metadata = {})
        data = {
          server_config: server_config.to_h
        }
        
        metadata = metadata.merge(operation: "config_show")
        format_success(data, metadata)
      end

      private

      def to_json(data)
        if pretty
          JSON.pretty_generate(data, {
            indent: "  ",
            space: " ",
            object_nl: "\n",
            array_nl: "\n"
          })
        else
          JSON.generate(data)
        end
      end

      def normalize_list_data(data)
        case data
        when Hash
          data.fetch("items", [])
        when Array
          data
        when NilClass
          []
        else
          [data]
        end
      end

      def build_server_description(config)
        case config.transport
        when "stdio"
          "#{config.command.join(' ')} (stdio)"
        when "sse"
          "#{config.url} (sse)"
        when "websocket"
          "#{config.url} (websocket)"
        else
          "#{config.transport} transport"
        end
      end
    end
  end
end
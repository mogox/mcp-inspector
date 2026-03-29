# frozen_string_literal: true
require "mcp_client"

module McpInspector
  module Transport
    class ClientAdapter < BaseAdapter
      def initialize(timeout: 30)
        super
        @client = nil
        @server_config = nil
      end

      def connect(server_config)
        @server_config = server_config
        
        begin
          with_timeout do
            case server_config.transport
            when "stdio"
              connect_stdio
            when "sse"
              connect_sse
            when "websocket"
              connect_websocket
            else
              raise ConnectionError, "Unsupported transport: #{server_config.transport}"
            end
          end
          @connected = true
        rescue => e
          @connected = false
          raise ConnectionError, "Failed to connect to #{server_config.name}: #{e.message}"
        end
      end

      def disconnect
        if @client && @client.respond_to?(:disconnect)
          @client.disconnect
        end
        @client = nil
        @connected = false
      end

      def list_tools
        with_timeout do
          response = @client.list_tools
          normalize_response(response)
        end
      rescue => e
        raise OperationError, "Failed to list tools: #{e.message}"
      end

      def list_resources
        if @client.respond_to?(:list_resources)
          with_timeout do
            response = @client.list_resources
            normalize_response(response)
          end
        else
          []
        end
      rescue => e
        raise OperationError, "Failed to list resources: #{e.message}"
      end

      def list_prompts
        if @client.respond_to?(:list_prompts)
          with_timeout do
            response = @client.list_prompts
            normalize_response(response)
          end
        else
          # Return empty prompts list if not supported
          []
        end
      rescue => e
        raise OperationError, "Failed to list prompts: #{e.message}"
      end

      def execute_tool(name, arguments = {})
        with_timeout do
          response = @client.call_tool(name, arguments)
          normalize_response(response)
        end
      rescue => e
        raise OperationError, "Failed to execute tool '#{name}': #{e.message}"
      end

      def read_resource(uri)
        if @client.respond_to?(:read_resource)
          with_timeout do
            response = @client.read_resource(uri)
            normalize_response(response)
          end
        else
          raise OperationError, "Resource reading is not supported by this server"
        end
      rescue => e
        raise OperationError, "Failed to read resource '#{uri}': #{e.message}"
      end

      def get_prompt(name, arguments = {})
        if @client.respond_to?(:get_prompt)
          with_timeout do
            response = @client.get_prompt(name, arguments)
            normalize_response(response)
          end
        else
          raise OperationError, "Prompts are not supported by this server"
        end
      rescue => e
        raise OperationError, "Failed to get prompt '#{name}': #{e.message}"
      end

      def server_info
        {
          name: @server_config.name,
          transport: @server_config.transport,
          connected: connected?,
          capabilities: detect_capabilities
        }
      end

      private

      def connect_stdio
        @client = MCPClient::ServerStdio.new(
          command: @server_config.command.join(' '),
          env: @server_config.env
        )
        @client.connect
      end

      def connect_sse
        @client = MCPClient::ServerSSE.new(base_url: @server_config.url)
        @client.connect
      end

      def connect_websocket
        @client = MCPClient::ServerHTTP.new(url: @server_config.url)
        @client.connect
      end

      def normalize_response(response)
        case response
        when Hash
          # Check if it's a hash with a "tools", "resources", "prompts", or "content" key
          if response.key?(:tools) || response.key?("tools")
            normalize_response(response[:tools] || response["tools"])
          elsif response.key?(:resources) || response.key?("resources")
            normalize_response(response[:resources] || response["resources"])
          elsif response.key?(:prompts) || response.key?("prompts")
            normalize_response(response[:prompts] || response["prompts"])
          elsif response.key?(:content) || response.key?("content")
            # Tool execution responses have a content array
            normalize_response(response[:content] || response["content"])
          else
            stringify_keys(response)
          end
        when Array
          return [] if response.empty?
          
          # Handle arrays of MCPClient objects
          if response.first.respond_to?(:name) && response.first.respond_to?(:description)
            # Array of Tool, Resource, or Prompt objects
            response.map { |item| normalize_mcp_object(item) }
          elsif response.first.is_a?(Hash)
            # Array of hashes - convert keys to strings
            response.map { |item| stringify_keys(item) }
          else
            response
          end
        else
          response
        end
      end

      def normalize_mcp_object(obj)
        # Safely extract name and description
        name = obj.respond_to?(:name) ? obj.name : nil
        description = obj.respond_to?(:description) ? obj.description : nil
        
        base_data = {
          name: name,
          description: description
        }
        
        # Add schema for tools (could be :schema, :inputSchema, or :input_schema)
        if obj.respond_to?(:schema) && obj.schema
          base_data[:inputSchema] = obj.schema
        elsif obj.respond_to?(:inputSchema) && obj.inputSchema
          base_data[:inputSchema] = obj.inputSchema
        elsif obj.respond_to?(:input_schema) && obj.input_schema
          base_data[:inputSchema] = obj.input_schema
        end
        
        # Add other properties that might exist
        base_data[:uri] = obj.uri if obj.respond_to?(:uri)
        base_data[:mimeType] = obj.mimeType if obj.respond_to?(:mimeType)
        base_data[:mime_type] = obj.mime_type if obj.respond_to?(:mime_type)
        
        # Convert symbol keys to string keys for view compatibility
        stringify_keys(base_data)
      end

      def stringify_keys(hash)
        return hash unless hash.is_a?(Hash)
        
        hash.each_with_object({}) do |(key, value), result|
          string_key = key.to_s
          result[string_key] = case value
          when Hash
            stringify_keys(value)
          when Array
            value.map { |item| item.is_a?(Hash) ? stringify_keys(item) : item }
          else
            value
          end
        end
      end

      def detect_capabilities
        capabilities = []
        
        begin
          list_tools
          capabilities << "tools"
        rescue OperationError
          # Tools not supported
        end

        begin
          list_resources
          capabilities << "resources"
        rescue OperationError
          # Resources not supported
        end

        begin
          list_prompts
          capabilities << "prompts"
        rescue OperationError
          # Prompts not supported
        end

        capabilities
      end
    end
  end
end
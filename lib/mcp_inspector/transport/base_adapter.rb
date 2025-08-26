# frozen_string_literal: true

module MCPInspector
  module Transport
    class BaseAdapter
      class ConnectionError < Error; end
      class OperationError < Error; end
      class TimeoutError < Error; end

      def initialize(timeout: 30)
        @timeout = timeout
        @connected = false
      end

      def connect(server_config)
        raise NotImplementedError, "Subclasses must implement #connect"
      end

      def disconnect
        raise NotImplementedError, "Subclasses must implement #disconnect"
      end

      def connected?
        @connected
      end

      def list_tools
        ensure_connected!
        raise NotImplementedError, "Subclasses must implement #list_tools"
      end

      def list_resources
        ensure_connected!
        raise NotImplementedError, "Subclasses must implement #list_resources"
      end

      def list_prompts
        ensure_connected!
        raise NotImplementedError, "Subclasses must implement #list_prompts"
      end

      def execute_tool(name, arguments = {})
        ensure_connected!
        raise NotImplementedError, "Subclasses must implement #execute_tool"
      end

      def read_resource(uri)
        ensure_connected!
        raise NotImplementedError, "Subclasses must implement #read_resource"
      end

      def get_prompt(name, arguments = {})
        ensure_connected!
        raise NotImplementedError, "Subclasses must implement #get_prompt"
      end

      def server_info
        ensure_connected!
        raise NotImplementedError, "Subclasses must implement #server_info"
      end

      private

      attr_reader :timeout

      def ensure_connected!
        raise ConnectionError, "Not connected to server" unless connected?
      end

      def with_timeout
        if timeout
          Timeout.timeout(timeout) { yield }
        else
          yield
        end
      rescue Timeout::Error
        raise TimeoutError, "Operation timed out after #{timeout} seconds"
      end
    end
  end
end
# frozen_string_literal: true

require "timeout"

module McpInspector
  module Web
    class ConnectionPool
      def initialize
        @connections = {}
        @mutex = Mutex.new
        @last_used = {}
        @max_idle_time = 300 # 5 minutes
      end

      # Get a connection for a server, reusing if available
      def with_connection(server_config)
        client = get_or_create_connection(server_config)

        begin
          yield client
        ensure
          update_last_used(server_config.name)
        end
      end

      # Get an existing connection or create a new one
      def get_or_create_connection(server_config)
        @mutex.synchronize do
          server_name = server_config.name

          # Check if we have an existing connection
          if @connections[server_name]
            client = @connections[server_name]

            # Verify the connection is still alive
            if connection_alive?(client)
              update_last_used(server_name)
              return client
            else
              # Connection is dead, remove it
              remove_connection(server_name)
            end
          end

          # Create new connection
          client = create_connection(server_config)
          @connections[server_name] = client
          update_last_used(server_name)

          client
        end
      end

      # Remove a specific connection
      def remove_connection(server_name)
        @mutex.synchronize do
          if @connections[server_name]
            begin
              @connections[server_name].disconnect
            rescue => e
              # Ignore disconnect errors
            end
            @connections.delete(server_name)
            @last_used.delete(server_name)
          end
        end
      end

      # Clean up idle connections
      def cleanup_idle_connections
        @mutex.synchronize do
          now = Time.now

          @connections.keys.each do |server_name|
            last_used = @last_used[server_name]

            if last_used && (now - last_used) > @max_idle_time
              remove_connection(server_name)
            end
          end
        end
      end

      # Disconnect all connections
      def disconnect_all
        @mutex.synchronize do
          @connections.each do |server_name, client|
            begin
              client.disconnect
            rescue => e
              # Ignore disconnect errors
            end
          end

          @connections.clear
          @last_used.clear
        end
      end

      private

      def create_connection(server_config)
        client = McpInspector::Transport::ClientAdapter.new

        Timeout.timeout(30) do
          client.connect(server_config)
        end

        client
      end

      def connection_alive?(client)
        return false unless client
        return false unless client.connected?

        # Could add additional health check here if needed
        true
      rescue
        false
      end

      def update_last_used(server_name)
        @last_used[server_name] = Time.now
      end
    end
  end
end

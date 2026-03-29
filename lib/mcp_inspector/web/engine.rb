# frozen_string_literal: true

require "rails"
require "turbo-rails"
require_relative "connection_pool"

module McpInspector
  module Web
    class Engine < ::Rails::Engine
      isolate_namespace McpInspector::Web

      # Set the engine root to the web directory
      config.root = File.expand_path(__dir__)

      # Configure paths for controllers, views, and helpers
      config.paths["app/controllers"] = "app/controllers"
      config.paths["app/views"] = "app/views"
      config.paths["app/helpers"] = "app/helpers"
      config.paths["config/routes.rb"] = "config/routes.rb"

      # Enable Turbo
      config.turbo.draw_routes = false

      # Initialize connection pool
      @connection_pool = ConnectionPool.new

      # Class method to access the connection pool
      def self.connection_pool
        @connection_pool
      end

      # Manually require controllers and helpers
      config.before_initialize do
        require_relative "app/helpers/mcp_inspector/web/ui_resources_helper"
        require_relative "app/controllers/mcp_inspector/web/application_controller"
        require_relative "app/controllers/mcp_inspector/web/dashboard_controller"
        require_relative "app/controllers/mcp_inspector/web/servers_controller"
        require_relative "app/controllers/mcp_inspector/web/operations_controller"
      end

      initializer "mcp_inspector.web.assets" do |app|
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/assets/javascripts")
      end

      # Cleanup idle connections periodically
      initializer "mcp_inspector.web.connection_cleanup" do |app|
        # Run cleanup every 5 minutes
        config.after_initialize do
          Thread.new do
            Thread.current.daemon = true
            loop do
              sleep 300 # 5 minutes
              McpInspector::Web::Engine.connection_pool.cleanup_idle_connections
            end
          end
        end
      end

      # Disconnect all connections on shutdown
      config.to_prepare do
        at_exit do
          McpInspector::Web::Engine.connection_pool.disconnect_all
        end
      end
    end
  end
end

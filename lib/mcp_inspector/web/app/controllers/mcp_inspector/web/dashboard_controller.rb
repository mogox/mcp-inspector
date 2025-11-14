# frozen_string_literal: true

module McpInspector
  module Web
    class DashboardController < ApplicationController
      def index
        @servers = config_manager.servers
        @selected_server = params[:server] || @servers.keys.first
      rescue McpInspector::Data::ConfigManager::ConfigError => e
        @servers = {}
        @config_error = e.message
      end
    end
  end
end

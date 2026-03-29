# frozen_string_literal: true

module McpInspector
  module Web
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :exception

      layout "mcp_inspector/web/application"

      helper McpInspector::Web::UiResourcesHelper

      private

      def config_manager
        @config_manager ||= McpInspector::Data::ConfigManager.new
      end

      def handle_mcp_error(error)
        render turbo_stream: turbo_stream.update("response_area", partial: "mcp_inspector/web/shared/error", locals: { error: error })
      end
    end
  end
end

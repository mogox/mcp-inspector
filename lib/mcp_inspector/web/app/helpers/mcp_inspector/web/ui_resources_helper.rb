# frozen_string_literal: true

require "base64"
require "securerandom"

module McpInspector
  module Web
    module UiResourcesHelper
      # Check if a result contains MCP UI resources
      # According to the protocol, check for ui:// URI scheme first
      def contains_ui_resources?(result)
        return false unless result.is_a?(Array)

        result.any? { |item| ui_resource?(item) }
      end

      # Check if a single item is a UI resource
      def ui_resource?(item)
        return false unless item.is_a?(Hash)

        # Check for ui:// URI scheme in the resource
        item.dig("resource", "uri")&.start_with?("ui://") ||
          item.dig(:resource, :uri)&.start_with?("ui://")
      end

      # Extract UI resources from a result array
      def extract_ui_resources(result)
        return [] unless result.is_a?(Array)

        result.select { |item| ui_resource?(item) }
      end

      # Extract non-UI content from a result array
      def extract_non_ui_content(result)
        return result unless result.is_a?(Array)

        result.reject { |item| ui_resource?(item) }
      end

      # Get the content from a UI resource, handling both text and blob encoding
      def ui_resource_content(ui_resource)
        resource = ui_resource["resource"] || ui_resource[:resource]
        return nil unless resource

        # Check for text content first
        if resource["text"] || resource[:text]
          return resource["text"] || resource[:text]
        end

        # Handle blob (base64 encoded) content
        if resource["blob"] || resource[:blob]
          blob = resource["blob"] || resource[:blob]
          return Base64.decode64(blob)
        end

        nil
      end

      # Get the MIME type of a UI resource
      def ui_resource_mime_type(ui_resource)
        resource = ui_resource["resource"] || ui_resource[:resource]
        resource&.dig("mimeType") || resource&.dig(:mimeType)
      end

      # Get the URI of a UI resource
      def ui_resource_uri(ui_resource)
        resource = ui_resource["resource"] || ui_resource[:resource]
        resource&.dig("uri") || resource&.dig(:uri)
      end

      # Determine the rendering mode based on MIME type
      def ui_resource_render_mode(ui_resource)
        mime_type = ui_resource_mime_type(ui_resource)
        return :unknown unless mime_type

        case mime_type
        when "text/html"
          :raw_html
        when "text/uri-list"
          :external_url
        when /^application\/vnd\.mcp-ui\.remote-dom/
          # Matches application/vnd.mcp-ui.remote-dom or
          # application/vnd.mcp-ui.remote-dom+javascript; framework=webcomponents
          :remote_dom
        else
          :unknown
        end
      end

      # Parse URI list content (RFC 2483)
      # Returns the first valid HTTP/HTTPS URL
      def parse_uri_list(content)
        return nil if content.blank?

        content.lines.each do |line|
          # Skip comments and blank lines
          next if line.strip.empty? || line.strip.start_with?("#")

          url = line.strip
          # Return first valid HTTP/HTTPS URL
          return url if url.match?(/^https?:\/\//)
        end

        nil
      end

      # Generate a unique ID for an iframe
      def ui_resource_iframe_id(ui_resource)
        uri = ui_resource_uri(ui_resource)
        # Create a safe ID from the URI
        uri&.gsub(/[^a-zA-Z0-9\-_]/, "-") || "ui-resource-#{SecureRandom.hex(4)}"
      end

      # Generate HTML for remote DOM execution
      def generate_remote_dom_html(script)
        <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <style>
              body {
                margin: 0;
                padding: 16px;
                font-family: system-ui, -apple-system, sans-serif;
              }
            </style>
          </head>
          <body>
            <div id="root"></div>
            <script>
              const root = document.getElementById('root');
              #{script}
            </script>
          </body>
          </html>
        HTML
      end
    end
  end
end

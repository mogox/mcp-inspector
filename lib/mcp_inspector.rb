# frozen_string_literal: true

require "zeitwerk"
require "timeout"

loader = Zeitwerk::Loader.for_gem
loader.setup

module MCPInspector
  class Error < StandardError; end
end

# Eagerly load CLI so it's available for the executable
require_relative "mcp_inspector/cli"
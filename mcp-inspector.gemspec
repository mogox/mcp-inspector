# frozen_string_literal: true

require_relative "lib/mcp_inspector/version"

Gem::Specification.new do |spec|
  spec.name = "mcp-inspector"
  spec.version = MCPInspector::VERSION
  spec.authors = ["Enrique Mogollan"]
  spec.email = ["emogollan@gmail.com"]

  spec.summary = "A tool for inspecting MCP (Model Context Protocol) servers"
  spec.description = "A Ruby gem that provides tooling for connecting to and inspecting MCP servers, allowing you to list and execute tools, resources, and prompts with JSON output."
  spec.homepage = "https://github.com/mogox/mcp-inspector"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mogox/mcp-inspector"
  spec.metadata["bug_tracker_uri"] = "https://github.com/mogox/mcp-inspector/issues"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "json", "~> 2.6"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "ruby-mcp-client", "~> 0.7.0"
  spec.add_dependency "base64"  # Required for ruby-mcp-client in Ruby 3.4+
  
  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

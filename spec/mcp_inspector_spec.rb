# frozen_string_literal: true

RSpec.describe McpInspector do
  it "has a version number" do
    expect(McpInspector::VERSION).not_to be nil
  end

  it "defines the main module" do
    expect(McpInspector).to be_a(Module)
  end

  it "defines the base error class" do
    expect(McpInspector::Error).to be < StandardError
  end
end
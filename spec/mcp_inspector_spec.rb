# frozen_string_literal: true

RSpec.describe MCPInspector do
  it "has a version number" do
    expect(MCPInspector::VERSION).not_to be nil
  end

  it "defines the main module" do
    expect(MCPInspector).to be_a(Module)
  end

  it "defines the base error class" do
    expect(MCPInspector::Error).to be < StandardError
  end
end
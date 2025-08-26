# frozen_string_literal: true

RSpec.describe MCPInspector::Presentation::JSONFormatter do
  let(:formatter) { described_class.new(pretty: false) }

  describe "#format_success" do
    it "formats successful responses with consistent structure" do
      data = { "test" => "value" }
      metadata = { "operation" => "test" }
      
      result = formatter.format_success(data, metadata)
      parsed = JSON.parse(result)
      
      expect(parsed["status"]).to eq("success")
      expect(parsed["data"]).to eq(data)
      expect(parsed["metadata"]["operation"]).to eq("test")
      expect(parsed["metadata"]["timestamp"]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    end
  end

  describe "#format_error" do
    it "formats error responses with consistent structure" do
      error = StandardError.new("Test error")
      metadata = { "operation" => "test" }
      
      result = formatter.format_error(error, metadata)
      parsed = JSON.parse(result)
      
      expect(parsed["status"]).to eq("error")
      expect(parsed["error"]["type"]).to eq("StandardError")
      expect(parsed["error"]["message"]).to eq("Test error")
    end
  end

  describe "#format_tools_list" do
    it "formats tools list with count" do
      tools = [{"name" => "tool1"}, {"name" => "tool2"}]
      
      result = formatter.format_tools_list(tools)
      parsed = JSON.parse(result)
      
      expect(parsed["status"]).to eq("success")
      expect(parsed["data"]["tools"]).to eq(tools)
      expect(parsed["data"]["count"]).to eq(2)
      expect(parsed["metadata"]["operation"]).to eq("list_tools")
    end
  end
end
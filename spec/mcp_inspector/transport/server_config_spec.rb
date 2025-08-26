# frozen_string_literal: true

RSpec.describe MCPInspector::Transport::ServerConfig do
  describe "#initialize" do
    context "with valid stdio configuration" do
      let(:config) do
        {
          "name" => "test-server",
          "transport" => "stdio",
          "command" => ["node", "server.js"]
        }
      end

      it "creates a valid server config" do
        server_config = described_class.new(config)
        
        expect(server_config.name).to eq("test-server")
        expect(server_config.transport).to eq("stdio")
        expect(server_config.command).to eq(["node", "server.js"])
        expect(server_config).to be_stdio
      end
    end

    context "with valid SSE configuration" do
      let(:config) do
        {
          "name" => "sse-server",
          "transport" => "sse",
          "url" => "http://localhost:8080/sse"
        }
      end

      it "creates a valid server config" do
        server_config = described_class.new(config)
        
        expect(server_config.name).to eq("sse-server")
        expect(server_config.transport).to eq("sse")
        expect(server_config.url).to eq("http://localhost:8080/sse")
        expect(server_config).to be_sse
      end
    end

    context "with invalid configuration" do
      it "raises ValidationError for missing required fields" do
        expect {
          described_class.new({})
        }.to raise_error(MCPInspector::Transport::ServerConfig::ValidationError)
      end

      it "raises ValidationError for invalid transport" do
        expect {
          described_class.new({
            "name" => "test",
            "transport" => "invalid"
          })
        }.to raise_error(MCPInspector::Transport::ServerConfig::ValidationError)
      end
    end
  end
end
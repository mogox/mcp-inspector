# frozen_string_literal: true

RSpec.describe MCPInspector::Data::ConfigManager do
  let(:temp_config_file) { "/tmp/test-mcp-inspector.json" }
  let(:user_config_file) { File.expand_path("~/.mcp-inspector.json") }
  let(:project_config_file) { "./.mcp-inspector.json" }
  
  after do
    # Clean up all config files that might be created during tests
    [temp_config_file, user_config_file, project_config_file].each do |file|
      File.delete(file) if File.exist?(file)
    end
  end

  describe "#initialize" do
    context "with valid configuration file" do
      before do
        # Make sure no other config files exist to avoid merging
        [user_config_file, project_config_file].each do |file|
          File.delete(file) if File.exist?(file)
        end
        
        config_data = {
          "servers" => [
            {
              "name" => "test-server",
              "transport" => "stdio",
              "command" => ["node", "server.js"]
            }
          ],
          "defaults" => {
            "output" => "json",
            "pretty" => true
          }
        }
        File.write(temp_config_file, JSON.generate(config_data))
      end

      it "loads the configuration successfully" do
        config_manager = described_class.new(config_path: temp_config_file)
        
        expect(config_manager.server_names).to eq(["test-server"])
        expect(config_manager.output_format).to eq("json")
        expect(config_manager.pretty_print?).to be true
      end
    end

    context "with missing configuration file" do
      before do
        # Clean up any existing configs to ensure we test the missing config scenario
        [user_config_file, project_config_file].each do |file|
          File.delete(file) if File.exist?(file)
        end
      end
      
      it "auto-creates config and raises ConfigError with helpful message" do
        nonexistent_path = "/tmp/nonexistent-test-config.json"
        
        expect {
          described_class.new(config_path: nonexistent_path)
        }.to raise_error(MCPInspector::Data::ConfigManager::ConfigError) do |error|
          expect(error.message).to include("No configuration file found, so I created one for you")
          expect(error.message).to include(nonexistent_path)
          expect(error.message).to include("filesystem-server")
          expect(error.message).to include("github-server")
        end
        
        # Verify the config file was actually created
        expect(File.exist?(nonexistent_path)).to be true
        
        # Clean up
        File.delete(nonexistent_path) if File.exist?(nonexistent_path)
      end
      
      it "auto-creates default user config when no path specified" do
        expect {
          described_class.new
        }.to raise_error(MCPInspector::Data::ConfigManager::ConfigError) do |error|
          expect(error.message).to include("No configuration file found, so I created one for you")
          expect(error.message).to include(user_config_file)
        end
        
        # Verify the default config file was created
        expect(File.exist?(user_config_file)).to be true
      end
    end
  end

  describe ".create_example_config" do
    it "creates a valid example configuration file" do
      path = described_class.create_example_config(temp_config_file)
      
      expect(File.exist?(path)).to be true
      
      config_data = JSON.parse(File.read(path))
      expect(config_data).to have_key("servers")
      expect(config_data).to have_key("defaults")
      expect(config_data["servers"]).to be_an(Array)
    end
  end
end
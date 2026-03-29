# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
# Configure Zeitwerk to ignore the conflicting 'lib' directory
lib_path = File.expand_path('../../lib', __dir__)
Rails.autoloaders.main.ignore(lib_path)

Rails.application.initialize!

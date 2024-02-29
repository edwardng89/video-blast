##
# Set encoding specifically for builds on Tempest Server
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

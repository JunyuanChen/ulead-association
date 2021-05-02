require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ulead
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.allow_concurrency = true

    config.rvt.whitelisted_ips = '0.0.0.0/0'
    config.rvt.automount = false
    config.rvt.command = '/bin/bash'
    config.rvt.timeout = 45.seconds

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.time_zone = 'Eastern Time (US & Canada)'
  end
end

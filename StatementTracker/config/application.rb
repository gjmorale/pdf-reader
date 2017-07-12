require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StatementTracker
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/file_reader)
    config.autoload_paths += %W(#{config.root}/lib/file_meta)
    config.autoload_paths += %W(#{config.root}/lib/file_manager)
    config.autoload_paths += %W(#{config.root}/lib/file_ghost)
    config.autoload_paths += %W(#{config.root}/lib/commit_params)
  end
end

require_relative "boot"

require "rails"

require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"
require "sprockets/railtie"
# remove all components dependent upon activerecord 
# require "active_model/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
# require "action_mailbox/engine"
# require "action_text/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Wthr
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
     
    # Application Specific
    
    # load env vars to pass to javascript
    Bundler.require(*Rails.groups)

    config.generators do |g|
      g.orm nil # This disables any ORM hooks, specifically ActiveRecord
    end


    # use rspec!
    config.generators.test_framework :rspec
  end
end

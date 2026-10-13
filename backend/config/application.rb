require_relative "boot"
require "rails"
require "action_controller/railtie"
require "active_support/railtie"
require "rails/test_unit/railtie"
require "rack/cors"
Bundler.require(*Rails.groups)

module VozDaFe
  class Application < Rails::Application
    config.load_defaults 7.2
    config.api_only = true
    config.time_zone = "Brasilia"
    config.eager_load_paths << Rails.root.join("app/services")

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins(*ENV.fetch("CORS_ORIGINS", "http://localhost:8080,http://localhost:3000").split(","))
        resource "/api/*", headers: :any, methods: %i[get post options]
      end
    end
  end
end

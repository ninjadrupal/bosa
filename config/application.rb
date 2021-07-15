require_relative 'boot'

require 'rails/all'
require 'rack/cors'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimAws
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.time_zone = "Europe/Paris"
    config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml').to_s]

    Redis.exists_returns_integer = false

    Decidim.unconfirmed_access_for = 0.days

    config.assets.initialize_on_precompile = false

    initializer "CORS" do
      if Rails.env.production?
        #
        # Keep it here in config/application.rb as it loads after the lib/decidim/api/engine.rb initialization.
        # To avoid multiple Rack::Cors middlewares and handle multiple CORS policies correctly we swap the middleware
        # from api/engine.rb with our own that should include the policies for /api and other resources.
        #
        # When not using `decidim-api` module, change it to the standard way of adding Rack::Cors middleware:
        # `Rails.application.config.middleware.insert_before 0, Rack::Cors do ...`
        #
        Rails.application.config.middleware.swap Rack::Cors, Rack::Cors do
          orgs_hosts = Decidim::Organization.all.collect do |org|
            [
              "https://#{org.host}",
              org.secondary_hosts.blank? ? [] : org.secondary_hosts.collect {|h| "https://#{h}"}
            ]
          end.flatten

          allow do
            origins "*"
            resource "/api", headers: :any, methods: [:post, :options]
          end
          allow do
            origins *orgs_hosts
            resource '*', headers: :any, methods: [:get, :post, :delete, :put, :patch, :options, :head]
          end
        end

        Rails.application.config.action_dispatch.default_headers['Cross-Origin-Embedder-Policy'] = 'unsafe-none'
        Rails.application.config.action_dispatch.default_headers['Cross-Origin-Opener-Policy'] = 'same-origin'
        Rails.application.config.action_dispatch.default_headers['Cross-Origin-Resource-Policy'] = 'same-origin'

        #
        # Requires to specify a <directive>:<allowlist> if any of the feature is used
        # Docs: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy
        #
        # Rails.application.config.action_dispatch.default_headers['Permissions-Policy'] = ''
      end
    end

    config.to_prepare do
      list = Dir.glob("#{Rails.root}/lib/extends/**/*.rb")
      concerns = list.select{|o| o.include?('concerns/')}
      if concerns.any?
        concerns.each {|c| puts "Concern: #{c}"}
        raise Exception, %Q{
        It looks like you're going to add an extension of a decidim concern.
        Putting it into lib/extends/ will lead to issues.
        Please override any of decidim concerns through classic monkey-patching and put them in the app/ folder.
      }
      end
      list.each {|override| require_dependency override}
    end

    initializer "Expire sessions" do
      Rails.application.config.session_store :active_record_store, key: '_decidim_session'
      ActiveRecord::SessionStore::Session.serializer = :json
    end

    # Remove decidim-api routes in favor of definition of `Decidim::Api::Engine.routes.draw` in config/routes.rb
    initializer "Remove default decidim-api routes" do |app|
      routes_paths = app.routes_reloader.paths
      decidim_api_route_path = routes_paths.select{ |path| path.include?("decidim-api/config/routes.rb") }.first

      if decidim_api_route_path.present?
        decidim_api_route_path_index = routes_paths.index(decidim_api_route_path)
        routes_paths.delete_at(decidim_api_route_path_index)
      end
    end

    Sentry.init do |config|
      config.logger = Sentry::Logger.new(STDOUT)
      config.dsn = "https://c3d3d789cfd241db940fcd8c8c2b81eb@o26574.ingest.sentry.io/5471760" # ENV["SENTRY_DSN"]
      config.enabled_environments = %w[staging production bosa-production bosa-cities-production bosa-uat bosa-cities-uat]
      config.environment = ENV.fetch("SENTRY_CURRENT_ENV", "missing-env")
      config.send_default_pii = true

      config.async = lambda do |event, hint|
        Sentry::SendEventJob.perform_later(event, hint)
      end
    end

    # config.action_mailer.asset_host = "https://broom.osp.cat"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Basic auth
    config.basic_auth_required = ENV.fetch('BASIC_AUTH_REQUIRED', 1).to_i == 1
    config.basic_auth_username = ENV['BASIC_AUTH_USERNAME']
    config.basic_auth_password = ENV['BASIC_AUTH_PASSWORD']
  end
end

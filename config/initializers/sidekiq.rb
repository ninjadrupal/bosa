require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/1' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/1' }
end

# This is required since we have changed the setup for the session storage
# and we need to pass session config from the rails app to the SidekiqUI(sinatra based app)
Sidekiq::Web.set :sessions, Rails.application.config.session_options
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_token]

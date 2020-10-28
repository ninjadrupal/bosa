# frozen_string_literal: true

source 'https://rubygems.org'

ruby RUBY_VERSION

DECIDIM_VERSION = { git: 'https://github.com/decidim/decidim', branch: 'release/0.22-stable' }

gem 'decidim', DECIDIM_VERSION
gem 'decidim-initiatives', DECIDIM_VERSION
gem 'decidim-verifications_omniauth', git: 'git@github.com:belighted/decidim-module-verifications_omniauth.git', branch: 'master'
gem 'decidim-initiatives_no_signature_allowed', git: 'https://github.com/belighted/decidim-module-initiatives_nosignature_allowed'
# gem 'decidim-suggestions', git: 'git@github.com:belighted/decidim-module-suggestions.git', branch: 'master'

# gem 'decidim-term_customizer', git: 'https://github.com/OpenSourcePolitics/decidim-module-term_customizer.git', branch: '0.dev'
# --------
# Fake update to 0.22
# It is using decidim v0.20 inside
# TODO: get back to original https://github.com/mainio/decidim-module-term_customizer AFTER they upgrade it to official decidim 0.22 (otherwise can't properly bundle install because of dependency versions resolution)
gem 'decidim-term_customizer', git: 'https://github.com/belighted/decidim-module-term_customizer.git', branch: 'fake-v0.22'

# gem 'decidim-cookies', git:'https://github.com/OpenSourcePolitics/decidim-module_cookies', branch: 'feature/orejime'
gem 'decidim-cookies', git: 'https://github.com/belighted/decidim-module-cookies'

# gem 'decidim-navbar_links', git: 'https://github.com/OpenSourcePolitics/decidim-module-navbar_links', branch: '0.22.0.dev'
# --------
# Fake update to 0.22
# It is using decidim v0.19 inside
# TODO: Update to latest 0.22 if needed (and after it is officially released, otherwise can't properly bundle install because of dependency versions resolution)
gem 'decidim-navbar_links', git: 'https://github.com/belighted/decidim-module-navbar_links', branch: 'fake-v0.22.0'

# ----------------------------------------------------------------------------------------------------------------------
# Avoid wicked_pdf require error
# gem 'akami', git: 'https://github.com/OpenSourcePolitics/akami', branch: 'fix-timestamp'
# gem 'akami', path: '../_lib/akami'
# gem 'omniauth-oauth2', '>= 1.4.0', '< 2.0'
# gem 'omniauth_openid_connect', '0.3.1'
gem 'activerecord-session_store'
gem 'bootsnap'
gem 'deepl-rb'
gem 'http_logger'
gem 'omniauth-rails_csrf_protection'
gem 'puma'
gem 'pry'
gem 'ruby-progressbar'
gem 'rubyzip', require: 'zip'
gem 'sentry-raven'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'uglifier'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

gem 'dotenv-rails'

group :development, :test do
  gem 'faker', '~> 1.9'
  gem 'byebug', '~> 11.0', platform: :mri
  gem 'decidim-dev', git: 'https://github.com/decidim/decidim', branch: 'release/0.22-stable'
  gem 'pry-rails'
  gem 'webdrivers'
end

group :development do
  gem 'capistrano', '~> 3.10', require: false
  gem 'capistrano-rails', '~> 1.6', require: false
  gem 'capistrano-rbenv', '~> 2.2', require: false
  gem 'capistrano-sidekiq', '2.0.0.beta5', require: false
  gem 'capistrano3-puma', require: false
  gem "capistrano-db-tasks", require: false
  gem 'letter_opener_web', '~> 1.3'
  gem 'listen', '~> 3.1'
  gem 'spring', '~> 2.0'
  gem 'spring-watcher-listen', '~> 2.0'
  gem 'web-console', '~> 3.5'
end

group :production do
  # gem 'dalli-elasticache'
  gem 'fog-aws'
  # gem 'newrelic_rpm'
  # gem 'newrelic-infinite_tracing'
end

group :test do
  gem 'database_cleaner-active_record'
end

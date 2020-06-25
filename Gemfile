# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# ----------------------------------------------------------------------------------------------------------------------
gem 'decidim', git: 'https://github.com/decidim/decidim', branch: "release/0.22-stable"

gem "decidim-verifications_omniauth", git: "https://github.com/belighted/decidim-module-verifications_omniauth"

gem "decidim-initiatives", git: 'https://github.com/decidim/decidim', branch: "release/0.22-stable"

gem "decidim-initiatives_no_signature_allowed", git: "https://github.com/belighted/decidim-module-initiatives_nosignature_allowed"

# gem "decidim-term_customizer", git: "https://github.com/OpenSourcePolitics/decidim-module-term_customizer.git", branch: "0.dev"
# --------
# Fake update to 0.22
# It is using decidim v0.20 inside
# TODO: get back to original https://github.com/mainio/decidim-module-term_customizer AFTER they upgrade it to official decidim 0.22 (otherwise can't properly bundle install because of dependency versions resolution)
gem "decidim-term_customizer", git: "https://github.com/belighted/decidim-module-term_customizer.git", branch: "fake-v0.22"


# gem "decidim-cookies", git:"https://github.com/OpenSourcePolitics/decidim-module_cookies", branch: "feature/orejime"
gem "decidim-cookies", git: "https://github.com/belighted/decidim-module-cookies"


# gem "decidim-navbar_links", git: "https://github.com/OpenSourcePolitics/decidim-module-navbar_links", branch: "0.22.0.dev"
# --------
# Fake update to 0.22
# It is using decidim v0.19 inside
# TODO: Update to latest 0.22 if needed (and after it is officially released, otherwise can't properly bundle install because of dependency versions resolution)
gem "decidim-navbar_links", git: "https://github.com/belighted/decidim-module-navbar_links", branch: "fake-v0.22.0"

# ----------------------------------------------------------------------------------------------------------------------

gem "bootsnap"
gem "puma"
gem "uglifier"

gem "faker", "~> 1.9"

# Avoid wicked_pdf require error
gem "wicked_pdf"
gem "wkhtmltopdf-binary"

gem "ruby-progressbar"
gem "sentry-raven"

gem "activerecord-session_store"

gem "omniauth-oauth2", ">= 1.4.0", "< 2.0"
gem "omniauth_openid_connect", "0.3.1"
gem "omniauth-saml", "~> 1.10"
gem "savon", "~> 2.12.0"
gem "akami", git: "https://github.com/OpenSourcePolitics/akami", branch: "fix-timestamp"

gem "dotenv-rails"
gem "rubyzip", require: "zip"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem 'pry-rails'

  gem "decidim-dev", git: 'https://github.com/decidim/decidim', branch: "release/0.22-stable"
  # gem "decidim-dev", path: "../decidim"
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :production do
  gem "newrelic_rpm"
  gem "sidekiq"
  gem "fog-aws"
  gem "dalli-elasticache"
end

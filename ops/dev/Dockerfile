FROM bosa-base:latest

ARG GITHUB_TOKEN

# Configure locale, bundler, define app dir
ENV BUNDLE_WITHOUT=production:test
ENV BUNDLE_WITH=development
ENV RAILS_ENV=development
ENV NODE_ENV=development

RUN git config --global url."https://$GITHUB_TOKEN:x-oauth-basic@github.com/".insteadOf git@github.com:

COPY Gemfile* /app/

# Upgrade RubyGems, add github to known_hosts, add .gitconfig, install required Bundler version
RUN bundle check || bundle install

FROM nexus-server.devops-tools.svc.cluster.local:8084/bosa-base:0.2.0
LABEL maintainer="Dominique Lebrun <dominique.lebrun@belighted.com>"
ENV BUNDLE_WITHOUT=test:development
ENV BUNDLE_WITH=production
ENV RAILS_ENV=production

COPY Gemfile* /app/
RUN bundle install

ADD . /app/

RUN mkdir -p /app/public/uploads/tmp
CMD rm -f /tmp/pid && bundle exec puma -C config/puma.rb

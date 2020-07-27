# frozen_string_literal: true
require "active_support/concern"

module ActionAuthorizerExtend
  extend ActiveSupport::Concern

  included do

    def authorize
      raise AuthorizationError, "Missing data" unless component && action

      Decidim::ActionAuthorizer::AuthorizationStatusCollection.new(authorization_handlers, user, component, resource, action)
    end

  end
end

module AuthorizationStatusCollectionExtend
  extend ActiveSupport::Concern

  included do

    def initialize(authorization_handlers, user, component, resource, action)
      @authorization_handlers = authorization_handlers
      @statuses = authorization_handlers&.map do |name, opts|
        handler = Decidim::Verifications::Adapter.from_element(name)
        authorization = user ? Decidim::Verifications::Authorizations.new(organization: user.organization, user: user, name: name).first : nil
        status_code, data = handler.authorize(authorization, opts["options"], component, resource, action)
        Decidim::ActionAuthorizer::AuthorizationStatus.new(status_code, handler, data)
      end
    end

  end
end

Decidim::ActionAuthorizer.send(:include, ActionAuthorizerExtend)

Decidim::ActionAuthorizer::AuthorizationStatusCollection.send(:include, AuthorizationStatusCollectionExtend)


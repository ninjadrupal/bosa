# frozen_string_literal: true

require "active_support/concern"

module VerificationsAdapterExtend
  extend ActiveSupport::Concern

  included do
    def authorize(authorization, options, component, resource, action)
      @action_authorizer = @manifest.action_authorizer_class.new(authorization, options_for_authorizer_class(options), component, resource, action)
      @action_authorizer.authorize
    end
  end
end

Decidim::Verifications::Adapter.send(:include, VerificationsAdapterExtend)

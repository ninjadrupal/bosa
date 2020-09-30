# frozen_string_literal: true

require "active_support/concern"

module AuthorizationModalsControllerExtend
  extend ActiveSupport::Concern

  included do
    include Decidim::UserProfile
    helper Decidim::Verifications::AntiAffinityHelper
  end
end

Decidim::AuthorizationModalsController.send(:include, AuthorizationModalsControllerExtend)

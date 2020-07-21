# frozen_string_literal: true
require "active_support/concern"

module AuthorizationSignModalsControllerExtend
  extend ActiveSupport::Concern

  included do

    include Decidim::UserProfile
    helper Decidim::Verifications::AntiAffinityHelper

  end
end

Decidim::Initiatives::AuthorizationSignModalsController.send(:include, AuthorizationSignModalsControllerExtend)

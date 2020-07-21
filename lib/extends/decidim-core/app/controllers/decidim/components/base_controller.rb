# frozen_string_literal: true
require "active_support/concern"

module BaseControllerExtend
  extend ActiveSupport::Concern

  included do

    helper Decidim::Verifications::AntiAffinityHelper

  end
end

Decidim::Components::BaseController.send(:include, BaseControllerExtend)

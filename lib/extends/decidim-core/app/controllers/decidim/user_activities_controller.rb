# frozen_string_literal: true

require "active_support/concern"

module UserActivitiesControllerExtend
  extend ActiveSupport::Concern

  included do
    def index
      # From Decidim commit https://github.com/decidim/decidim/commit/d6671d458cbe6dda53514d07bed09e6cd9c8836f
      raise ActionController::RoutingError, "Missing user: #{params[:nickname]}" unless user
    end
  end
end

Decidim::UserActivitiesController.send(:include, UserActivitiesControllerExtend)

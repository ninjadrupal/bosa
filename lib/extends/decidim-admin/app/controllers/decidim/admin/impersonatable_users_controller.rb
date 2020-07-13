# frozen_string_literal: true
require "active_support/concern"

module AdminImpersonatableUsersControllerExtend
  extend ActiveSupport::Concern

  included do
    def new_managed_user
      Decidim::User.new(managed: true, admin: false, roles: [], organization: current_organization)
    end
  end
end

Decidim::Admin::ImpersonatableUsersController.send(:include, AdminImpersonatableUsersControllerExtend)

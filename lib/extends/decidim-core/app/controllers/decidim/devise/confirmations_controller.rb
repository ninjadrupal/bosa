# frozen_string_literal: true

require "active_support/concern"

module DeviseConfirmationsControllerExtend
  extend ActiveSupport::Concern

  included do
    def after_resending_confirmation_instructions_path_for(resource_name)
      return request.referer if resource_name == :user && user_signed_in?

      super
    end
  end
end

Decidim::Devise::ConfirmationsController.send(:include, DeviseConfirmationsControllerExtend)

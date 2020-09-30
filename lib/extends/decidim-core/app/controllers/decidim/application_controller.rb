# frozen_string_literal: true

require "active_support/concern"

module ApplicationControllerExtend
  extend ActiveSupport::Concern

  included do
    helper Decidim::DeeplHelper

    def skip_store_location?
      # Skip if Devise already handles the redirection
      return true if devise_controller? && redirect_url.blank?
      # Skip for all non-HTML requests"
      return true unless request.format.html?
      # Skip if a signed in user requests the TOS page without having agreed to
      # the TOS. Most of the times this is because of a redirect to the TOS
      # page (in which case the desired location is somewhere else after the
      # TOS is agreed).
      return true if current_user && !current_user.tos_accepted? && same_path?(request.path, tos_path)

      false
    end

    def same_path?(path1, path2)
      path1.split("?").first == path2.split("?").first
    end
  end
end

Decidim::ApplicationController.send(:include, ApplicationControllerExtend)

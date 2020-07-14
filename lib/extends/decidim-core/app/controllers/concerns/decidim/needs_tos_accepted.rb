# frozen_string_literal: true
require "active_support/concern"

module NeedsTosAcceptedExtend
  extend ActiveSupport::Concern

  included do
    private

    def redirect_to_tos
      # Store the location where the user needs to be redirected to after the
      # TOS is agreed.
      store_location_for(
        current_user,
        stored_location_for(current_user) || request.fullpath
      )

      flash[:notice] = flash[:notice] if flash[:notice]
      flash[:secondary] = t("required_review.alert", scope: "decidim.pages.terms_and_conditions")
      redirect_to tos_path
    end
  end
end

Decidim::NeedsTosAccepted.send(:include, NeedsTosAcceptedExtend)

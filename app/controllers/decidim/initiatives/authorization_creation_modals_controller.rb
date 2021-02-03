# frozen_string_literal: true

module Decidim
  module Initiatives
    class AuthorizationCreationModalsController < Decidim::Initiatives::ApplicationController
      include Decidim::UserProfile
      include Decidim::Initiatives::NeedsInitiative

      helper InitiativeHelper
      helper Decidim::Verifications::AntiAffinityHelper
      helper_method :authorizations, :authorize_action_path

      def show
        if current_organization.initiatives_settings_allow_to?(current_user, 'create')
          render template: "decidim/authorization_modals/show", layout: false
        else
          render template: "decidim/initiatives/initiatives/_organization_initiatives_settings_validation_message", layout: false
        end
      end

      private

      def redirect_url
        params[:redirect] || create_initiative_path(:select_initiative_type)
      end

      def authorize_action_path(handler_name)
        authorizations.status_for(handler_name).current_path(redirect_url: redirect_url)
      end

      def authorizations
        @authorizations ||= Decidim::Initiatives::InitiativeTypes.for(current_organization).map do |type|
          action_authorized_to("create", resource: type, permissions_holder: type)
        end.reject(&:ok?).first
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Suggestions
    class AuthorizationCreationModalsController < Decidim::Suggestions::ApplicationController
      include Decidim::UserProfile
      include Decidim::Suggestions::NeedsSuggestion

      helper SuggestionHelper
      helper Decidim::Verifications::AntiAffinityHelper
      helper_method :authorizations, :authorize_action_path

      def show
        if current_organization.suggestions_settings_allow_to?(current_user, 'create')
          render template: "decidim/authorization_modals/show", layout: false
        else
          render template: "decidim/suggestions/suggestions/_organization_suggestions_settings_validation_message", layout: false
        end
      end

      private

      def redirect_url
        params[:redirect] || create_suggestion_path(:select_suggestion_type)
      end

      def authorize_action_path(handler_name)
        authorizations.status_for(handler_name).current_path(redirect_url: redirect_url)
      end

      def authorizations
        @authorizations ||= Decidim::Suggestions::SuggestionTypes.for(current_organization).map do |type|
          action_authorized_to("create", resource: type, permissions_holder: type)
        end.reject(&:ok?).first
      end
    end
  end
end

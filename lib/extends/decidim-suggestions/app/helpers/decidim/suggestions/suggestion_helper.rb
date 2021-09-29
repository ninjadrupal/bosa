# frozen_string_literal: true

require "active_support/concern"

module SuggestionHelperExtend
  extend ActiveSupport::Concern

  included do
    # include Decidim::Verifications::MetadataHelper

    def authorized_creation_modal_button_to(action, html_options, &block)
      html_options ||= {}

      if !current_user
        html_options["data-open"] = "loginModal"
        html_options["data-redirect-url"] = action
        request.env[:available_authorizations] = merged_permissions_for(:create)
      else
        html_options["data-open"] = "authorizationModal"
        html_options["data-open-url"] = suggestions_authorization_creation_modal_path(redirect: action)
      end

      html_options["onclick"] = "event.preventDefault();"

      send("button_to", "", html_options, &block)
    end

    def permissions_for(action, type)
      return [] unless type.permissions && type.permissions.dig(action.to_s, "authorization_handlers")

      type.permissions.dig(action.to_s, "authorization_handlers").keys
    end

    # rubocop:disable Style/MultilineBlockChain
    def merged_permissions_for(action)
      Decidim::Suggestions::SuggestionTypes.for(current_organization).map do |type|
        permissions_for(action, type)
      end.inject do |result, list|
        result + list
      end&.uniq
    end
    # rubocop:enable Style/MultilineBlockChain

  end
end

Decidim::Suggestions::SuggestionHelper.send(:include, SuggestionHelperExtend)

# frozen_string_literal: true

require "active_support/concern"

module SuggestionsPermissionsExtend
  extend ActiveSupport::Concern

  included do

    private

    def creation_enabled?
      Decidim::Suggestions.creation_enabled &&
      user.admin? && (
      Decidim::Suggestions.do_not_require_authorization ||
        Decidim::Suggestions::UserAuthorizations.for(user).any? ||
        Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?
      )
    end

  end
end

Decidim::Suggestions::Permissions.send(:include, SuggestionsPermissionsExtend)

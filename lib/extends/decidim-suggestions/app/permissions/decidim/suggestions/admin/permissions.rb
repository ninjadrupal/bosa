# frozen_string_literal: true

require "active_support/concern"

module SuggestionsAdminPermissionsExtend
  extend ActiveSupport::Concern

  included do

    private

    def allowed_to_send_to_technical_validation?
      suggestion.created? && (
        user.admin? ||
        !suggestion.created_by_individual? ||
        suggestion.enough_committee_members?
      )
    end

  end
end

Decidim::Suggestions::Admin::Permissions.send(:include, SuggestionsAdminPermissionsExtend)

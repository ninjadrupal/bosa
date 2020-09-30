# frozen_string_literal: true

require "active_support/concern"

module VoteCellExtend
  extend ActiveSupport::Concern

  included do
    def user_scope
      metadata[:user_scope]
    end

    def resident
      metadata[:resident]
    end

    def scope
      return I18n.t("decidim.scopes.global") if model.decidim_scope_id.nil?
      return I18n.t("decidim.initiatives.unavailable_scope") if model.scope.blank?

      translated_attribute(model.scope.name)
    end
  end
end

Decidim::InitiativesVotes::VoteCell.send(:include, VoteCellExtend)

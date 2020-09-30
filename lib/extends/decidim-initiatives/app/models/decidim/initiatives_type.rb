# frozen_string_literal: true

require "active_support/concern"

module InitiativesTypeExtend
  extend ActiveSupport::Concern

  included do
    before_update :update_global_scope, if: :missing_global_scope?

    private

    def missing_global_scope?
      only_global_scope_enabled? && scopes.present? && !scopes.include?(nil)
    end

    def update_global_scope
      total_required = scopes.sum(&:supports_required)
      Decidim::InitiativesTypeScope.new(
        supports_required: total_required,
        decidim_scopes_id: nil,
        decidim_initiatives_types_id: id
      ).save
    end
  end
end

Decidim::InitiativesType.send(:include, InitiativesTypeExtend)

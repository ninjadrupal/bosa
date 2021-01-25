# frozen_string_literal: true

require "active_support/concern"

module InitiativeFormExtend
  extend ActiveSupport::Concern

  included do

    validates :description, length: {maximum: 4000}

    def scope_id
      return nil if initiative_type.only_global_scope_enabled?

      super.presence
    end

    def initiative_type
      @initiative_type ||= Decidim::InitiativesType.find(type_id)
    end

    def available_scopes
      @available_scopes ||= if initiative_type.only_global_scope_enabled?
                              initiative_type.scopes.where(scope: nil)
                            else
                              initiative_type.scopes
                            end
    end

    def scope
      @scope ||= Decidim::Scope.find(scope_id) if scope_id.present?
    end

    private

    # def scope_exists
    #   return if scope_id.blank?
    #
    #   errors.add(:scope_id, :invalid) unless InitiativesTypeScope.where(type: initiative_type, scope: scope).exists?
    # end

    def type
      @type ||= Decidim::InitiativesType.find(type_id)
    end
  end
end

Decidim::Initiatives::InitiativeForm.send(:include, InitiativeFormExtend)

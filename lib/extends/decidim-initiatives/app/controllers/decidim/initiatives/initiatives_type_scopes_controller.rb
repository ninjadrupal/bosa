# frozen_string_literal: true
require "active_support/concern"

module InitiativesTypeScopesControllerExtend
  extend ActiveSupport::Concern

  included do

    private

    def scoped_types
      @scoped_types ||= if initiative_type.only_global_scope_enabled?
                          initiative_type.scopes.where(scope: nil)
                        else
                          initiative_type.scopes
                        end
    end

    def initiative_type
      @initiative_type ||= Decidim::InitiativesType.find(params[:type_id])
    end

  end
end

Decidim::Initiatives::InitiativesTypeScopesController.send(:include, InitiativesTypeScopesControllerExtend)

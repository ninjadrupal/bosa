# frozen_string_literal: true

require "active_support/concern"

module InitiativesControllerExtend
  extend ActiveSupport::Concern

  included do
    helper Decidim::ActionAuthorizationHelper
    include Decidim::Initiatives::SingleInitiativeType

    # GET /initiatives/:id/signature_identities
    def signature_identities
      @voted_groups = []

      render layout: false
    end

    private

    def default_filter_params
      {
        search_text: "",
        state: %w(accepted rejected answered open closed examinated debatted classified),
        type_id: default_filter_type_params,
        author: "any",
        scope_id: default_filter_scope_params,
        area_id: default_filter_area_params,
        custom_state: [""]
      }
    end

  end
end

Decidim::Initiatives::InitiativesController.send(:include, InitiativesControllerExtend)

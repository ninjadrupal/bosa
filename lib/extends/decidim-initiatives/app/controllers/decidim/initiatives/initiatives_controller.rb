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

    def fetched_initiatives
      initiatives = search.results.includes(:scoped_type)
      initiatives = reorder(initiatives)
      paginate(initiatives)
    end

    def initiatives
      @initiatives ||= fetched_initiatives
    end

    def default_filter_params
      {
        search_text: "",
        state: ["open"],
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

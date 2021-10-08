# frozen_string_literal: true

require "active_support/concern"

module ProposalsControllerExtend
  extend ActiveSupport::Concern

  included do

    private

    def default_filter_params
      {
        search_text: "",
        origin: default_filter_origin_params,
        activity: "all",
        category_id: default_filter_category_params,
        state: %w(accepted evaluating not_answered rejected),
        scope_id: default_filter_scope_params,
        related_to: "",
        type: "all"
      }
    end

  end
end

Decidim::Proposals::ProposalsController.send(:include, ProposalsControllerExtend)

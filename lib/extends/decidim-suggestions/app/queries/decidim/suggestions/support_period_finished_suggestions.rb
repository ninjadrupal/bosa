# frozen_string_literal: true

require "active_support/concern"

module SupportPeriodFinishedSuggestionsExtend
  extend ActiveSupport::Concern

  included do

    def query
      Decidim::Suggestion
        .includes(:scoped_type)
        .where(state: "published")
        .where(signature_type: "any") # given allowed_signature_types_for_suggestions is only 'any'
        .where("signature_end_date < ?", Date.current)
    end

  end
end

Decidim::Suggestions::SupportPeriodFinishedSuggestions.send(:include, SupportPeriodFinishedSuggestionsExtend)

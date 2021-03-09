# frozen_string_literal: true

require "active_support/concern"

module SuggestionExtend
  extend ActiveSupport::Concern

  included do

    has_many :suggestions_areas, foreign_key: "decidim_suggestion_id", class_name: "Decidim::SuggestionsArea", dependent: :destroy
    has_many :areas, through: :suggestions_areas

    def accepts_offline_votes?
      true
    end

  end
end

Decidim::Suggestion.send(:include, SuggestionExtend)

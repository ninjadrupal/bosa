# frozen_string_literal: true

module Decidim
  # The data store for a Initiative in the Decidim::Initiatives component.
  class SuggestionsArea < ApplicationRecord

    belongs_to :suggestion, foreign_key: "decidim_suggestion_id", class_name: "Decidim::Suggestion"

    belongs_to :area, foreign_key: "decidim_area_id", class_name: "Decidim::Area"

    validates_presence_of :suggestion, :area
    validates :area, uniqueness: {scope: :suggestion}

  end
end

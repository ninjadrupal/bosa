# frozen_string_literal: true

require "active_support/concern"

module SuggestionsTypeExtend
  extend ActiveSupport::Concern

  included do

    def allowed_signature_types_for_suggestions
      return %w(any)
    end

  end
end

Decidim::SuggestionsType.send(:include, SuggestionsTypeExtend)

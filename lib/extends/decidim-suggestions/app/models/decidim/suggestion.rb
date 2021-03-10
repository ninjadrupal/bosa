# frozen_string_literal: true

require "active_support/concern"

module SuggestionExtend
  extend ActiveSupport::Concern

  included do

    def accepts_offline_votes?
      true
    end

  end
end

Decidim::Suggestion.send(:include, SuggestionExtend)

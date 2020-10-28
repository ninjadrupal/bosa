# frozen_string_literal: true

require "active_support/concern"

module SuggestionFormExtend
  extend ActiveSupport::Concern

  included do

    attribute :offline_votes, Integer

    validates :offline_votes,
              numericality: {
                only_integer: true,
                greater_than: 0
              }, allow_blank: true

  end
end

Decidim::Suggestions::SuggestionForm.send(:include, SuggestionFormExtend)

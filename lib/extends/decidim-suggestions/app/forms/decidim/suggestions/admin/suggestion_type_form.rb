# frozen_string_literal: true

require "active_support/concern"

module SuggestionTypeFormExtend
  extend ActiveSupport::Concern

  included do

    def signature_type_options
      [
        [
          I18n.t(
            "any",
            scope: %w(activemodel attributes suggestion signature_type_values)
          ), "any"
        ]
      ]
    end

  end
end

Decidim::Suggestions::Admin::SuggestionTypeForm.send(:include, SuggestionTypeFormExtend)

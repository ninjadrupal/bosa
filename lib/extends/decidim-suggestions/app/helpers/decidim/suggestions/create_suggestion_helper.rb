# frozen_string_literal: true

require "active_support/concern"

module CreateSuggestionHelperExtend
  extend ActiveSupport::Concern

  included do

    def signature_type_options(suggestion_form)
      offline_signature_type_options
    end

    private

    def offline_signature_type_options
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

Decidim::Suggestions::CreateSuggestionHelper.send(:include, CreateSuggestionHelperExtend)

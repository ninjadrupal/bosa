# frozen_string_literal: true

require "active_support/concern"

module CreateSuggestionExtend
  extend ActiveSupport::Concern

  included do

    private

    def build_suggestion
      Decidim::Suggestion.new(
        organization: form.current_organization,
        title: { current_locale => form.title },
        description: { current_locale => form.description },
        author: current_user,
        decidim_user_group_id: form.decidim_user_group_id,
        scoped_type: scoped_type,
        area: area,
        signature_type: form.signature_type,
        signature_end_date: signature_end_date,
        offline_votes: form.offline_votes,
        state: "created"
      )
    end

  end
end

Decidim::Suggestions::CreateSuggestion.send(:include, CreateSuggestionExtend)

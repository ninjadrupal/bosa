# frozen_string_literal: true

require "active_support/concern"

module SuggestionsEngineExtend
  extend ActiveSupport::Concern

  included do
    routes do
      get "authorization_creation_modal", to: "authorization_creation_modals#show"
    end
  end
end

Decidim::Suggestions::Engine.send(:include, SuggestionsEngineExtend)

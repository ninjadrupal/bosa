# frozen_string_literal: true

require "active_support/concern"

module SuggestionsPreviousFormExtend
  extend ActiveSupport::Concern

  included do

    clear_validators!
    validates :title, :description, presence: true
    validates :type_id, presence: true

  end
end

Decidim::Suggestions::PreviousForm.send(:include, SuggestionsPreviousFormExtend)

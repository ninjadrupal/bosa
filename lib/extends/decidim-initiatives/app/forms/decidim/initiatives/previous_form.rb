# frozen_string_literal: true

require "active_support/concern"

module InitiativesPreviousFormExtend
  extend ActiveSupport::Concern

  included do

    clear_validators!
    validates :title, :description, presence: true
    validates :type_id, presence: true

  end
end

Decidim::Initiatives::PreviousForm.send(:include, InitiativesPreviousFormExtend)

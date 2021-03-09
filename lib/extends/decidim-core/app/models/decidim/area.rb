# frozen_string_literal: true

require "active_support/concern"

module AreaExtend
  extend ActiveSupport::Concern

  included do
    attribute :color
    attribute :logo

    mount_uploader :logo, Decidim::AreaLogoUploader

    has_many :suggestions_areas, foreign_key: "decidim_area_id", class_name: "Decidim::SuggestionsArea", dependent: :destroy
    has_many :suggestions, through: :suggestions_areas

  end
end

Decidim::Area.send(:include, AreaExtend)

# frozen_string_literal: true
require "active_support/concern"

module UpdateAreaExtend
  extend ActiveSupport::Concern

  included do

    private

    def attributes
      {
        name: form.name,
        area_type: form.area_type,
        color: form.color,
        logo: form.logo,
        remove_logo: form.remove_logo
      }
    end

  end
end

Decidim::Admin::UpdateArea.send(:include, UpdateAreaExtend)

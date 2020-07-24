# frozen_string_literal: true
require "active_support/concern"

module CreateAreaExtend
  extend ActiveSupport::Concern

  included do

    private

    def create_area
      Decidim.traceability.create!(
        Area,
        form.current_user,
        name: form.name,
        organization: form.organization,
        area_type: form.area_type,
        color: form.color,
        logo: form.logo
      )
    end

  end
end

Decidim::Admin::CreateArea.send(:include, CreateAreaExtend)

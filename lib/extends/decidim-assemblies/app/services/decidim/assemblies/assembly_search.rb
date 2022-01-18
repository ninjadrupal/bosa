# frozen_string_literal: true

require "active_support/concern"

module AssemblySearchExtend
  extend ActiveSupport::Concern

  included do

    def search_area_id
      return query if area_id.blank?

      query.includes(:areas).references(:decidim_areas).where("decidim_areas.id IN (?)", area_id.map(&:to_i))
    end

  end
end

Decidim::Assemblies::AssemblySearch.send(:include, AssemblySearchExtend)

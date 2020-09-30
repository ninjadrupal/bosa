# frozen_string_literal: true

require "active_support/concern"

module DiffCellExtend
  extend ActiveSupport::Concern

  included do
    def diff_renderer_class
      if current_version.item_type.deconstantize == "Decidim"
        "#{current_version.item_type.pluralize}::DiffRenderer".constantize
      else
        "#{current_version.item_type.deconstantize}::DiffRenderer".constantize
      end
    rescue NameError
      Decidim::BaseDiffRenderer
    end
  end
end

Decidim::DiffCell.send(:include, DiffCellExtend)

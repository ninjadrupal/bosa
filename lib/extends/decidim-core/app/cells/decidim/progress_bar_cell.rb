# frozen_string_literal: true

require "active_support/concern"

module ProgressBarCellExtend
  extend ActiveSupport::Concern

  included do
    def container_class
      container_class = "progress__bar"
      container_class += " progress__bar--horizontal" if horizontal? && !small?
      container_class += " progress__bar--vertical" if vertical?
      container_class
    end

    def display_subtitle?
      subtitle_text.present? && !small? && !horizontal?
    end

    def vertical?
      !small? && !horizontal?
    end

    def horizontal?
      options[:horizontal].to_s == "true"
    end
  end
end

Decidim::ProgressBarCell.send(:include, ProgressBarCellExtend)

# frozen_string_literal: true
require "active_support/concern"

module DebatesDebateMCellExtend
  extend ActiveSupport::Concern

  included do

    def translatable?
      true
    end

  end
end

Decidim::Debates::DebateMCell.send(:include, DebatesDebateMCellExtend)

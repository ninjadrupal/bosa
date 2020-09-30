# frozen_string_literal: true

require "active_support/concern"

module AreaExtend
  extend ActiveSupport::Concern

  included do
    attribute :color
    attribute :logo

    mount_uploader :logo, Decidim::AreaLogoUploader
  end
end

Decidim::Area.send(:include, AreaExtend)

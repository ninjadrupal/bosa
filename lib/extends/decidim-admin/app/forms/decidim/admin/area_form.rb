# frozen_string_literal: true
require "active_support/concern"

module AreaFormExtend
  extend ActiveSupport::Concern

  included do

    attribute :color
    attribute :logo
    attribute :remove_logo

    validates :logo,
              file_size: {less_than_or_equal_to: ->(_record) {Decidim.maximum_attachment_size}},
              file_content_type: {allow: ["image/png"]}
    validates :color, format: {with: /#[0-9a-fA-F]{6}|#[0-9a-fA-F]{3}/i}

  end
end

Decidim::Admin::AreaForm.send(:include, AreaFormExtend)

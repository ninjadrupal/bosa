# frozen_string_literal: true

require "active_support/concern"

module StaticPageFormExtend
  extend ActiveSupport::Concern

  included do

    validates :slug, format: {with: %r{\A[a-zA-Z]+[a-zA-Z0-9\-\_]+\z}}, allow_blank: true

  end
end

Decidim::Admin::StaticPageForm.send(:include, StaticPageFormExtend)

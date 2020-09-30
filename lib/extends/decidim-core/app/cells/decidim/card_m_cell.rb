# frozen_string_literal: true

require "active_support/concern"

module CardMCellExtend
  extend ActiveSupport::Concern

  included do
    include Decidim::DeeplHelper
    include Decidim::LanguageChooserHelper

    private

    def default_locale
      current_organization.default_locale
    end

    def current_locale
      I18n.locale.to_s
    end

    def translatable?
      false
    end
  end
end

Decidim::CardMCell.send(:include, CardMCellExtend)

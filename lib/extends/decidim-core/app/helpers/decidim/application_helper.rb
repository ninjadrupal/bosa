# frozen_string_literal: true

require "active_support/concern"

module ApplicationHelperExtend
  extend ActiveSupport::Concern

  included do
    def translated_in_current_locale(attribute)
      return if attribute.nil?

      attribute[I18n.locale.to_s].present?
    end
  end
end

Decidim::ApplicationHelper.send(:include, ApplicationHelperExtend)

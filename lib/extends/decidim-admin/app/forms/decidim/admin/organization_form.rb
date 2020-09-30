# frozen_string_literal: true

require "active_support/concern"

module OrganizationFormExtend
  extend ActiveSupport::Concern

  included do
    attribute :deepl_api_key, String
  end
end

Decidim::Admin::OrganizationForm.send(:include, OrganizationFormExtend)

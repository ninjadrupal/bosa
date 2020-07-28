# frozen_string_literal: true
require "active_support/concern"

module ValidateMobilePhoneExtend
  extend ActiveSupport::Concern

  included do

    private

    def authorizer
      return unless authorization

      Decidim::Verifications::Adapter.from_element(authorization_name).authorize(authorization, {}, nil, nil, nil)
    end

  end
end

Decidim::Initiatives::ValidateMobilePhone.send(:include, ValidateMobilePhoneExtend)

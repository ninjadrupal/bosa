# frozen_string_literal: true
require "active_support/concern"

module InitiativesControllerExtend
  extend ActiveSupport::Concern

  included do
    # GET /initiatives/:id/signature_identities
    def signature_identities
      @voted_groups = []

      render layout: false
    end
  end
end

Decidim::Initiatives::InitiativesController.send(:include, InitiativesControllerExtend)

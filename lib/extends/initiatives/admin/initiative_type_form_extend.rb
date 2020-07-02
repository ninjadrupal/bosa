# frozen_string_literal: true
require "active_support/concern"

module InitiativeTypeFormExtend
  extend ActiveSupport::Concern

  included do

    attribute :attachments_enabled, Boolean
    attribute :child_scope_threshold_enabled, Boolean
    attribute :custom_signature_end_date_enabled, Boolean
    attribute :area_enabled, Boolean
    attribute :only_global_scope_enabled, Boolean

    attribute :comments_enabled, Boolean

    validates :attachments_enabled, :undo_online_signatures_enabled, :custom_signature_end_date_enabled,
              :promoting_committee_enabled, :area_enabled, inclusion: { in: [true, false] }

  end
end

Decidim::Initiatives::Admin::InitiativeTypeForm.class_eval do
  include InitiativeTypeFormExtend
end

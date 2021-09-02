# frozen_string_literal: true

require "active_support/concern"

module AdminUpdateInitiativeExtend
  extend ActiveSupport::Concern

  included do

    private

    def add_admin_accessible_attrs(attrs)
      attrs[:no_signature] = form.no_signature
      attrs[:signature_start_date] = form.signature_start_date
      attrs[:signature_end_date] = form.signature_end_date
      attrs[:offline_votes] = form.offline_votes if form.offline_votes
      attrs[:state] = form.state if form.state
      attrs[:decidim_area_id] = form.area_id
      attrs[:area_ids] = form.area_ids.reject(&:blank?)

      if initiative.published?
        @notify_extended = true if form.signature_end_date != initiative.signature_end_date &&
                                   form.signature_end_date > initiative.signature_end_date
      end
    end
  end
end

Decidim::Initiatives::Admin::UpdateInitiative.send(:include, AdminUpdateInitiativeExtend)

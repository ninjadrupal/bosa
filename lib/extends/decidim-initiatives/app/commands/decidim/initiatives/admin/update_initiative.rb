# frozen_string_literal: true

require "active_support/concern"

module UpdateInitiativeExtend
  extend ActiveSupport::Concern

  included do
    def initialize(initiative, form, current_user)
      @form = form
      @initiative = initiative
      @current_user = current_user
      @attached_to = initiative
    end

    def call
      return broadcast(:invalid) if form.invalid?

      if process_attachments?
        @initiative.attachments.destroy_all

        build_attachment
        return broadcast(:invalid) if attachment_invalid?
      end

      @initiative = Decidim.traceability.update!(
        initiative,
        current_user,
        attributes
      )
      create_attachment if process_attachments?
      notify_initiative_is_extended if @notify_extended
      broadcast(:ok, initiative)
    rescue ActiveRecord::RecordInvalid
      broadcast(:invalid, initiative)
    end

    private

    attr_reader :form, :initiative, :current_user, :attachment

    def attributes
      attrs = {
        title: form.title,
        description: form.description,
        hashtag: form.hashtag
      }

      if form.signature_type_updatable?
        attrs[:signature_type] = form.signature_type
        attrs[:scoped_type_id] = form.scoped_type_id if form.scoped_type_id
      end

      if current_user.admin?
        add_admin_accessible_attrs(attrs)
      elsif initiative.created?
        attrs[:signature_end_date] = form.signature_end_date if initiative.custom_signature_end_date_enabled?
        attrs[:decidim_area_id] = form.area_id if initiative.area_enabled?
      end

      attrs
    end

    def add_admin_accessible_attrs(attrs)
      attrs[:signature_start_date] = form.signature_start_date
      attrs[:signature_end_date] = form.signature_end_date
      attrs[:offline_votes] = form.offline_votes if form.offline_votes
      attrs[:state] = form.state if form.state
      attrs[:decidim_area_id] = form.area_id

      if initiative.published?
        @notify_extended = true if form.signature_end_date != initiative.signature_end_date &&
                                   form.signature_end_date > initiative.signature_end_date
      end
    end
  end
end

Decidim::Initiatives::Admin::UpdateInitiative.send(:include, UpdateInitiativeExtend)

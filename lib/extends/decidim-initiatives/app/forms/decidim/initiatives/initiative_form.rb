# frozen_string_literal: true

require "active_support/concern"

module InitiativeFormExtend
  extend ActiveSupport::Concern

  included do

    validates :description, length: {maximum: 4000}

    private


    def notify_missing_attachment_if_errored
      return if attachment.blank? || attachment.file.blank?

      errors.add(:attachment, :needs_to_be_reattached) if errors.any?
    end

    def trigger_attachment_errors
      return if attachment.blank? || attachment.file.blank?
      return if attachment.valid?

      if attachment.errors.has_key?(:title)
        errors.add(:attachment, :title)
        errors.add(:attachment, :needs_to_be_reattached)
      elsif errors.keys.reject {|k| k == :attachment}.blank?
        attachment.errors.each {|error| errors.add(:attachment, error)}
        attachment = Attachment.new(file: attachment.try(:file))
        errors.add(:attachment, :file) if !attachment.save && attachment.errors.has_key?(:file)
      end
    end
  end
end

Decidim::Initiatives::InitiativeForm.send(:include, InitiativeFormExtend)

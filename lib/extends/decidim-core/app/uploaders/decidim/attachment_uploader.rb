# frozen_string_literal: true

require "active_support/concern"

module AttachmentUploaderExtend
  extend ActiveSupport::Concern

  included do
    protected

    def extension_whitelist
      %w(jpg jpeg png pdf doc docx xls xlsx rtf odt)
    end

  end
end

Decidim::AttachmentUploader.send(:include, AttachmentUploaderExtend)

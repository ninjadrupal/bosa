# frozen_string_literal: true
require "active_support/concern"

module AttachmentUploaderExtend
  extend ActiveSupport::Concern

  included do

    protected

    def extension_white_list
      %w(pdf)
    end

    # CarrierWave automatically calls this method and validates the content
    # type fo the temp file to match against any of these options.
    def content_type_whitelist
      [
        %r{application\/pdf}
      ]
    end

  end
end

Decidim::AttachmentUploader.send(:include, AttachmentUploaderExtend)

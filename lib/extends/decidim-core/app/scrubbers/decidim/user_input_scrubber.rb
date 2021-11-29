# frozen_string_literal: true

require "active_support/concern"

module UserInputScrubberExtend
  extend ActiveSupport::Concern

  included do

    private

    def custom_allowed_attributes
      # Add `data-list` attribute to handle quill-2.0.0-dev.3 issue with OL/UL lists
      Loofah::HTML5::SafeList::ALLOWED_ATTRIBUTES + %w(frameborder allowfullscreen) + %w(data-list)
    end

  end
end

Decidim::UserInputScrubber.send(:include, UserInputScrubberExtend)

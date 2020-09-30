# frozen_string_literal: true

require "active_support/concern"

module LastActivityCellExtend
  extend ActiveSupport::Concern

  included do
    cache :show do
      Digest::MD5.hexdigest(activities.map(&:updated_at).to_s)
    end
  end
end

Decidim::ContentBlocks::LastActivityCell.send(:include, LastActivityCellExtend)

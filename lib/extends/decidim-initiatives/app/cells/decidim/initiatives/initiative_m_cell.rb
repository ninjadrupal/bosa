# frozen_string_literal: true
require "active_support/concern"

module InitiativeMCellExtend
  extend ActiveSupport::Concern

  included do

    include Decidim::Initiatives::InitiativeHelper

    cache :show do
      Digest::MD5.hexdigest(cache_hash)
    end

    private

    def cache_hash
      hash = model.author.cache_version +
        model.cache_version +
        model.supports_count.to_s +
        comments_count.to_s

      hash << current_user.follows?(model).to_s if current_user

      hash
    end

    def translatable?
      true
    end

    def state_classes
      case state
        when "accepted", "published", "debatted"
          ["success"]
        when "rejected", "discarded", "classified"
          ["alert"]
        when "validating", "examinated"
          ["warning"]
        else
          ["muted"]
      end
    end

    def has_area_color?
      model.area_color.present?
    end

    def area_color_style
      "style=\"background-color:#{model.area_color};\""
    end

    def area_logo
      model.area_logo
    end

    def area_name
      translated_attribute(model.area_name)
    end

    def comments_count
      return 0 unless model.type.comments_enabled
      return model.comments.not_hidden.count if model.comments.respond_to? :not_hidden

      model.comments.count
    end

    def comments_count_status
      return unless model.type.comments_enabled
      return render_comments_count unless has_link_to_resource?

      link_to resource_path do
        render_comments_count
      end
    end

  end
end

Decidim::Initiatives::InitiativeMCell.send(:include, InitiativeMCellExtend)

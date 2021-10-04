# frozen_string_literal: true

require "active_support/concern"

module ExportManifestExtend
  extend ActiveSupport::Concern

  included do

    def serializer(serializer = nil, forced: false)
      @serializer = serializer || Decidim::Exporters::Serializer if forced
      @serializer ||= serializer || Decidim::Exporters::Serializer
    end

  end
end

Decidim::Exporters::ExportManifest.send(:include, ExportManifestExtend)

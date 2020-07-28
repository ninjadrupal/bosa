# frozen_string_literal: true
require "active_support/concern"

module FilterResourceExtend
  extend ActiveSupport::Concern

  included do

    def filter
      Rails.cache.fetch("filter_params_#{filter_params}") do
        @filter ||= Decidim::Filter.new(filter_params)
      end
    end

  end
end

Decidim::FilterResource.send(:include, FilterResourceExtend)

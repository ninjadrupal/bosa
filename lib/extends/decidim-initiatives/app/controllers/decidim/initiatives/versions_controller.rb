# frozen_string_literal: true
require "active_support/concern"

module VersionsControllerExtend
  extend ActiveSupport::Concern

  included do

    helper Decidim::TraceabilityHelper

    private

    def current_version
      return nil unless params[:id].to_i.positive?

      @current_version ||= current_initiative.versions[params[:id].to_i - 1]
    end

  end
end

Decidim::Initiatives::VersionsController.send(:include, VersionsControllerExtend)

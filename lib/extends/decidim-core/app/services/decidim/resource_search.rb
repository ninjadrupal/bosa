# frozen_string_literal: true

module ResourceSearchExtend
  extend ActiveSupport::Concern

  included do
    # Note: the ResourceSearch has been completely refactored at beginning of 2022
    # Searchlight has been replaced by Ransack
    def base_query
      # raise "Missing component" unless component
      raise ActionController::RoutingError, "Not Found" unless component

      @scope.where(component: component)
    end
  end
end

Decidim::ResourceSearch.send(:include, ResourceSearchExtend)

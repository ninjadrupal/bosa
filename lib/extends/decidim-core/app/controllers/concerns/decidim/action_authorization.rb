# frozen_string_literal: true

require "active_support/concern"

module ActionAuthorizationExtend
  extend ActiveSupport::Concern

  included do
    def action_authorization_cache_key(action, resource, permissions_holder = nil)
      if resource && resource.try(:component) && !resource.permissions.nil?
        "#{action}-#{resource.component.id}-#{resource.resource_manifest.name}-#{resource.id}"
      elsif resource && permissions_holder
        "#{action}-#{permissions_holder.class.name}-#{permissions_holder.id}-#{resource.resource_manifest.name}-#{resource.id}"
      elsif permissions_holder
        "#{action}-#{permissions_holder.class.name}-#{permissions_holder.id}"
      else
        "#{action}-#{current_component.id}"
      end
    end
  end
end

Decidim::ActionAuthorization.send(:include, ActionAuthorizationExtend)

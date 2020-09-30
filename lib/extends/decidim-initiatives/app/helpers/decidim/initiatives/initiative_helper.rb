# frozen_string_literal: true

require "active_support/concern"

module InitiativeHelperExtend
  extend ActiveSupport::Concern

  included do
    include Decidim::Verifications::MetadataHelper

    # Public: The css class applied based on the initiative state to
    #         the initiative badge.
    #
    # initiative - Decidim::Initiative
    #
    # Returns a String.
    def state_badge_css_class(initiative)
      return "success" if initiative.accepted? || initiative.debatted? || initiative.published?
      return "alert" if initiative.classified?

      "warning"
    end

    # Public: The state of an initiative in a way a human can understand.
    #
    # initiative - Decidim::Initiative.
    #
    # Returns a String.
    def humanize_state(initiative)
      I18n.t(initiative.accepted? ? "accepted" : "expired",
             scope: "decidim.initiatives.states",
             default: :expired)
      return I18n.t("expired", scope: "decidim.initiatives.states") if initiative.rejected?

      I18n.t(initiative.state, scope: "decidim.initiatives.states")
    end

    # Public: The state of an initiative in a way a human can understand.
    #
    # initiative - Decidim::Initiative.
    #
    # Returns a String.
    def humanize_initiative_state(initiative)
      I18n.t(initiative.state, scope: "decidim.initiatives.state", default: :created)
    end

    def authorized_vote_modal_button(initiative, html_options, &block)
      return if current_user && action_authorized_to("vote", resource: initiative, permissions_holder: initiative.type).ok?

      tag = "button"
      html_options ||= {}
      action = initiative_initiative_signatures_path(initiative_slug: initiative.slug)

      if !current_user
        html_options["data-open"] = "loginModal"
        html_options["data-redirect-url"] = action
        request.env[:available_authorizations] = permissions_for(:vote, initiative.type)
      else
        html_options["data-open"] = "authorizationModal"
        html_options["data-open-url"] = authorization_sign_modal_initiative_path(initiative, redirect: action)
      end

      html_options["onclick"] = "event.preventDefault();"

      send("#{tag}_to", "", html_options, &block)
    end

    def can_edit_custom_signature_end_date?(initiative)
      return false unless initiative.custom_signature_end_date_enabled?

      initiative.created? || initiative.validating?
    end

    def can_edit_area?(initiative)
      return false unless initiative.area_enabled?

      initiative.created? || initiative.validating?
    end

    def authorized_creation_modal_button_to(action, html_options, &block)
      html_options ||= {}

      if !current_user
        html_options["data-open"] = "loginModal"
        html_options["data-redirect-url"] = action
        request.env[:available_authorizations] = merged_permissions_for(:create)
      else
        html_options["data-open"] = "authorizationModal"
        html_options["data-open-url"] = authorization_creation_modal_path(redirect: action)
      end

      html_options["onclick"] = "event.preventDefault();"

      send("button_to", "", html_options, &block)
    end

    def authorized_creation_modal_for_type_button_to(type, action, html_options, &block)
      html_options ||= {}

      if !current_user
        html_options["data-open"] = "loginModal"
        binder = action.include?("?") ? "&" : "?"
        html_options["data-redirect-url"] = "#{action}#{binder}type_id=#{type.id}"
        request.env[:available_authorizations] = merged_permissions_for(:create)
      else
        html_options["data-open"] = "authorizationModal"
        html_options["data-open-url"] = authorization_creation_modal_initiative_type_path(type.id, redirect: action)
      end

      html_options["onclick"] = "event.preventDefault();"

      send("button_to", "", html_options, &block)
    end

    def metadata_modal_button_to(authorization, html_options, &block)
      html_options ||= {}
      html_options["data-open"] = "authorizationModal"
      html_options["data-open-url"] = authorization_router(authorization).metadata_authorization_path(authorization)
      html_options["onclick"] = "event.preventDefault();"
      send("button_to", "", html_options, &block)
    end

    def any_initiative_types_authorized?
      return unless current_user

      Decidim::Initiatives::InitiativeTypes.for(current_user.organization).inject do |result, type|
        result && Decidim::ActionAuthorizer.new(current_user, :create, type, type).authorize.ok?
      end
    end

    def permissions_for(action, type)
      return [] unless type.permissions && type.permissions.dig(action.to_s, "authorization_handlers")

      type.permissions.dig(action.to_s, "authorization_handlers").keys
    end

    # rubocop:disable Style/MultilineBlockChain
    def merged_permissions_for(action)
      Decidim::Initiatives::InitiativeTypes.for(current_organization).map do |type|
        permissions_for(action, type)
      end.inject do |result, list|
        result + list
      end&.uniq
    end
    # rubocop:enable Style/MultilineBlockChain

    def authorizations
      @authorizations ||= Decidim::Verifications::Authorizations.new(
        organization: current_organization,
        user: current_initiative.author,
        granted: true,
        name: (action_authorized_to("create", resource: current_initiative, permissions_holder: current_initiative.type).statuses || []).map(&:handler_name)
      )
    end

    def action_authorized_to(action, resource: nil, permissions_holder: nil)
      action_authorization_cache[action_authorization_cache_key(action, resource, permissions_holder)] ||=
        ::Decidim::ActionAuthorizer.new(current_initiative.author, action, permissions_holder || resource&.component || current_component, resource).authorize
    end

    def action_authorization_cache
      request.env["decidim.action_authorization_cache"] ||= {}
    end

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

    def authorization_router(_authorization)
      Decidim::Verifications.find_workflow_manifest(@authorizations.first.name).admin_engine.routes.url_helpers
    end

    def display_badge?(initiative)
      initiative.rejected? || initiative.accepted? || initiative.debatted? || initiative.examinated? || initiative.classified?
    end
  end
end

Decidim::Initiatives::InitiativeHelper.send(:include, InitiativeHelperExtend)

# frozen_string_literal: true
require "active_support/concern"

module PermissionsExtend
  extend ActiveSupport::Concern

  # Changes moved from decidim-module-initiatives_nosignature_allowed

  included do

    def permissions
      if read_admin_dashboard_action?
        user_can_read_admin_dashboard?
        return permission_action
      end

      # Delegate the admin permission checks to the admin permissions class
      return Decidim::Initiatives::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
      return permission_action if permission_action.scope != :public

      # Non-logged users permissions
      public_report_content_action?
      list_public_initiatives?
      read_public_initiative?
      search_initiative_types_and_scopes?

      return permission_action unless user

      create_initiative?
      create_initiative_with_type?
      request_membership?

      vote_initiative?
      sign_initiative?
      unvote_initiative?

      initiative_attachment?

      permission_action
    end

    private

    def initiative_type
      @initiative_type ||= context.fetch(:initiative_type, nil) || initiative.type
    end

    def creation_enabled?
      Decidim::Initiatives.creation_enabled && (
      creation_authorized? || Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?
      )
    end

    def create_initiative_with_type?
      return unless permission_action.subject == :initiative_type &&
        permission_action.action == :create

      toggle_allow(creation_enabled_for?(initiative_type))
    end

    def creation_enabled_for?(initiative_type)
      Decidim::Initiatives.creation_enabled && (
      creation_authorized_for?(initiative_type) || Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?
      )
    end

    def request_membership?
      return unless permission_action.subject == :initiative &&
        permission_action.action == :request_membership

      can_request = !initiative.published? &&
        initiative.promoting_committee_enabled? &&
        !initiative.has_authorship?(user) &&
        (
        Decidim::Initiatives.do_not_require_authorization ||
          UserAuthorizations.for(user).any? ||
          Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?
        )

      toggle_allow(can_request)
    end

    def creation_authorized?
      return true if Decidim::Initiatives.do_not_require_authorization
      return true if available_verification_workflows.empty?

      Decidim::Initiatives::InitiativeTypes.for(user.organization).find do |type|
        Decidim::ActionAuthorizer.new(user, :create, type, type).authorize.ok?
      end.present?
    end

    def creation_authorized_for?(initiative_type)
      return true if Decidim::Initiatives.do_not_require_authorization
      return true if available_verification_workflows.empty?

      Decidim::ActionAuthorizer.new(user, :create, initiative_type, initiative_type).authorize.ok?
    end

    def unvote_initiative?
      return unless permission_action.action == :unvote &&
        permission_action.subject == :initiative

      can_unvote = initiative.accepts_online_unvotes? &&
        initiative.organization&.id == user.organization&.id &&
        initiative.votes.where(author: user).any? &&
        (can_user_support?(initiative) || Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?) &&
        authorized?(:vote, resource: initiative, permissions_holder: initiative.type)

      toggle_allow(can_unvote)
    end

    def can_vote?
      return if initiative.no_signature?

      initiative.votes_enabled? &&
        initiative.organization&.id == user.organization&.id &&
        initiative.votes.where(author: user).empty? &&
        (can_user_support?(initiative) || Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?) &&
        authorized?(:vote, resource: initiative, permissions_holder: initiative.type)
    end

  end
end

Decidim::Initiatives::Permissions.send(:include, PermissionsExtend)

# frozen_string_literal: true

require "active_support/concern"

module VoteInitiativeExtend
  extend ActiveSupport::Concern

  included do
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the proposal vote.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      percentage_before = initiative.percentage
      scopes_percentages_before = {}
      initiative.votable_initiative_type_scopes.each do |type_scope|
        scopes_percentages_before[type_scope.id] = initiative.percentage_for(type_scope.scope)
      end

      Decidim::Initiative.transaction do
        create_votes
      end

      percentage_after = initiative.reload.percentage

      send_notification
      notify_percentage_change(percentage_before, percentage_after)
      notify_support_threshold_reached(percentage_before, percentage_after)
      initiative.votable_initiative_type_scopes.each do |type_scope|
        notify_support_threshold_reached_for(type_scope, scopes_percentages_before[type_scope.id], initiative.percentage_for(type_scope.scope))
      end

      broadcast(:ok, votes)
    end

    attr_reader :votes

    private

    attr_reader :form

    delegate :initiative, to: :form

    def create_votes
      @votes = form.authorized_scopes.map do |scope|
        initiative.votes.create!(
          author: form.signer,
          encrypted_metadata: form.encrypted_metadata,
          timestamp: timestamp,
          hash_id: form.hash_id,
          scope: scope
        )
      end
    end

    def timestamp
      return unless timestamp_service

      @timestamp ||= timestamp_service.new(document: form.encrypted_metadata).timestamp
    end

    def send_notification
      Decidim::EventsManager.publish(
        event: "decidim.events.initiatives.initiative_endorsed",
        event_class: Decidim::Initiatives::EndorseInitiativeEvent,
        resource: initiative,
        followers: initiative.author.followers
      )
    end

    def notify_percentage_change(before, after)
      percentage = [25, 50, 75, 100].find do |milestone|
        before < milestone && after >= milestone
      end

      percentage = 100 if before != after && after == 100

      return unless percentage

      Decidim::EventsManager.publish(
        event: "decidim.events.initiatives.milestone_completed",
        event_class: Decidim::Initiatives::MilestoneCompletedEvent,
        resource: initiative,
        affected_users: [initiative.author],
        followers: initiative.followers - [initiative.author],
        extra: {
          percentage: percentage
        }
      )
    end

    def notify_support_threshold_reached(before, after)
      # Don't need to notify if threshold has already been reached
      return if before == after || after != 100

      Decidim::EventsManager.publish(
        event: "decidim.events.initiatives.support_threshold_reached",
        event_class: Decidim::Initiatives::Admin::SupportThresholdReachedEvent,
        resource: initiative,
        affected_users: organization_admins
      )
    end

    def notify_support_threshold_reached_for(type_scope, before, after)
      # Don't need to notify for global scopes
      return if type_scope.global_scope?

      # Don't need to notify if threshold has already been reached
      return if before == after || after != 100

      Decidim::EventsManager.publish(
        event: "decidim.events.initiatives.support_threshold_reached_for_scope",
        event_class: Decidim::Initiatives::SupportThresholdReachedForScopeEvent,
        resource: initiative,
        affected_users: [initiative.author],
        extra: {
          scope: type_scope.scope
        }
      )
      Decidim::EventsManager.publish(
        event: "decidim.events.initiatives.admin.support_threshold_reached_for_scope",
        event_class: Decidim::Initiatives::Admin::SupportThresholdReachedForScopeEvent,
        resource: initiative,
        affected_users: organization_admins,
        extra: {
          scope: type_scope.scope
        }
      )
    end

    def organization_admins
      Decidim::User.where(organization: initiative.organization, admin: true)
    end
  end
end

Decidim::Initiatives::VoteInitiative.send(:include, VoteInitiativeExtend)

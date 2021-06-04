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

      Decidim::Initiative.transaction do
        create_votes
      end

      initiative_scope_list = initiative.votable_initiative_type_scopes
      scope_after = {}

      initiative_scope_list.each do |initiatives_type_scope|
        scope_after[initiatives_type_scope.decidim_scopes_id] =
          initiative.votes.where(decidim_scope_id: initiatives_type_scope.decidim_scopes_id).count unless initiatives_type_scope.decidim_scopes_id.nil?
      end

      percentage_after = initiative.reload.percentage

      send_notification
      notify_percentage_change(percentage_before, percentage_after)
      notify_support_threshold_reached(percentage_after)
      notify_support_threshold_reached_for_scopes(scope_after)

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

    def notify_support_threshold_reached(percentage)
      return unless percentage >= 100

      Decidim::EventsManager.publish(
        event: "decidim.events.initiatives.support_threshold_reached",
        event_class: Decidim::Initiatives::Admin::SupportThresholdReachedEvent,
        resource: initiative,
        followers: organization_admins
      )
    end

    def notify_support_threshold_reached_for_scopes(scopes)
      scopes.each do |k,v|
        next if initiative.percentage_for_scope(k, v) != 100

        scope = initiative.votable_initiative_type_scopes.find{ |s| s.decidim_scopes_id == k}.scope

        Decidim::EventsManager.publish(
          event: "decidim.events.initiatives.milestone_completed.support_threshold_reached_for_scope",
          event_class: Decidim::Initiatives::SupportThresholdReachedForScopeEvent,
          resource: initiative,
          affected_users: [initiative.author],
          extra: {
            scope: scope
          }
        )
      end
    end

    def organization_admins
      Decidim::User.where(organization: initiative.organization, admin: true)
    end
  end
end

Decidim::Initiatives::VoteInitiative.send(:include, VoteInitiativeExtend)

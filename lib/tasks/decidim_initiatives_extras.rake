# frozen_string_literal: true

namespace :decidim_initiatives do
  desc "Check published initiatives and moves to accepted/rejected state depending on the votes collected when the signing period has finished"
  task check_published: :environment do
    Decidim::Initiatives::SupportPeriodFinishedInitiatives.new.each do |initiative|
      if initiative.supports_goal_reached?
        initiative.accepted!
      else
        initiative.rejected!
      end

      Decidim::EventsManager.publish(
        event: "decidim.events.initiatives.support_period_finished",
        event_class: Decidim::Initiatives::SupportPeriodFinishedEvent,
        resource: initiative,
        affected_users: [initiative.author],
        force_send: true
      )

      Decidim::EventsManager.publish(
        event: "decidim.events.initiatives.admin.support_period_finished",
        event_class: Decidim::Initiatives::Admin::SupportPeriodFinishedEvent,
        resource: initiative,
        affected_users: initiative.organization.admins,
        force_send: true
      )
    end
  end
end

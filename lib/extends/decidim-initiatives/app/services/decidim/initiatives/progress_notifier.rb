# frozen_string_literal: true

require "active_support/concern"

module ProgressNotifierExtend
  extend ActiveSupport::Concern

  included do
    def notify
      initiative.followers.each do |follower|
        next unless initiative.author != follower

        Decidim::Initiatives::InitiativesMailer
          .notify_progress(initiative, follower)
          .deliver_later
      end

      initiative.committee_members.approved.each do |committee_member|
        next unless initiative.author != committee_member.user

        Decidim::Initiatives::InitiativesMailer
          .notify_progress(initiative, committee_member.user)
          .deliver_later
      end
      Decidim::Initiatives::InitiativesMailer
        .notify_progress(initiative, initiative.author)
        .deliver_later
    end
  end
end

Decidim::Initiatives::ProgressNotifier.send(:include, ProgressNotifierExtend)

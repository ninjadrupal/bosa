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
    end
  end
end

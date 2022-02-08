# frozen_string_literal: true

namespace :users do
  desc "Clean user sign_in IP older than 24h"
  task clean_sign_in_ips: :environment do

    Decidim::User.
      where("current_sign_in_at < ?", Time.now - 24.hours).
      update_all(current_sign_in_ip: nil, last_sign_in_ip: nil)

  end
end

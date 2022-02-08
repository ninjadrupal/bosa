# frozen_string_literal: true

namespace :db do
  namespace :decidim_authorizations do

    desc "Delete socio-demographic authorization records after specified period of time"
    task clean_socio_demographic_authorization_handlers_data: :environment do
      # Brucity
      Decidim::Authorization.where(name: :brucity_socio_demographic_authorization_handler).
        where("granted_at < ?", Date.today - 1.year).
        delete_all
    end

  end
end

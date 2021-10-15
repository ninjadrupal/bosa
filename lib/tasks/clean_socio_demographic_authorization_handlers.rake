# frozen_string_literal: true

namespace :db do
  namespace :decidim_authorizations do

    desc "Delete socio_demographic_authorization_handler records after specified period of time"
    task clean_socio_demographic_authorization_handlers: :environment do
      Decidim::Authorization.where(name: :socio_demographic_authorization_handler).
        where("granted_at < ?", Date.today - 1.year).
        delete_all
    end

  end
end

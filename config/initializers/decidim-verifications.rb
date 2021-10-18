# frozen_string_literal: true

require "decidim/verifications/omniauth/bosa_action_authorizer"

Decidim::Verifications.unregister_workflow(:csv_census)
Decidim::Verifications.unregister_workflow(:id_documents)
Decidim::Verifications.unregister_workflow(:postal_letter)
Decidim::Verifications.unregister_workflow(:sms)

Decidim::Verifications.register_workflow(:dummy_authorization_handler) do |workflow|
  workflow.form = "DummyAuthorizationHandler"
  # workflow.action_authorizer = "DummyActionAuthorizer"

  if Rails.env.test?
    workflow.action_authorizer = "DummyAuthorizationHandler::DummyActionAuthorizer"
    workflow.expires_in = 1.hour
    workflow.renewable = true
    workflow.time_between_renewals = 5.minutes

    workflow.options do |options|
      options.attribute :postal_code, type: :string, default: "08001", required: false
    end
  end
end

if Rails.env.test?
  Decidim::Verifications.register_workflow(:another_dummy_authorization_handler) do |workflow|
    workflow.form = "AnotherDummyAuthorizationHandler"
    workflow.expires_in = 1.hour

    workflow.options do |options|
      options.attribute :passport_number, type: :string, required: false
    end
  end
end

Decidim::Verifications.register_workflow(:socio_demographic_authorization_handler) do |workflow|
  workflow.form = "SocioDemographicAuthorizationHandler"
  workflow.renewable = true
  workflow.time_between_renewals = 0.days
end

Decidim::Verifications.register_workflow(:brucity_socio_demographic_authorization_handler) do |workflow|
  workflow.form = "BrucitySocioDemographicAuthorizationHandler"
  workflow.renewable = true
  workflow.time_between_renewals = 0.days
  workflow.expires_in = 1.year
end

Decidim::Verifications.register_workflow(:csam) do |workflow|
  workflow.engine = Decidim::Verifications::Omniauth::Engine
  workflow.admin_engine = Decidim::Verifications::Omniauth::AdminEngine
  workflow.action_authorizer = "Decidim::Verifications::Omniauth::BosaActionAuthorizer"
  # workflow.form = "Decidim::Verifications::Omniauth::OmniauthAuthorizationForm"
  workflow.omniauth_provider = :csam
  # workflow.minimum_age = 16
  # workflow.expires_in = 24.hours
end

Decidim::Verifications.register_workflow(:saml) do |workflow|
  workflow.engine = Decidim::Verifications::Omniauth::Engine
  workflow.admin_engine = Decidim::Verifications::Omniauth::AdminEngine
  workflow.action_authorizer = "Decidim::Verifications::Omniauth::BosaActionAuthorizer"
  # workflow.form = "Decidim::Verifications::Omniauth::OmniauthAuthorizationForm"
  workflow.omniauth_provider = :saml
  # workflow.minimum_age = 16
  # workflow.expires_in = 24.hours
end

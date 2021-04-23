# frozen_string_literal: true

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.

::Devise.setup do |config|
  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  config.timeout_in = 30.minutes
end

require "omniauth/strategies/eid_saml"
require "omniauth/strategies/eid_csam"

Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth.config.logger = Rails.logger
  OneLogin::RubySaml::Logging.logger = Rails.logger

  omniauth_config = Rails.application.secrets.dig(:omniauth)

  if omniauth_config[:saml].present?
    provider(
      OmniAuth::Strategies::EidSaml,
      setup: setup_provider_proc(
        :saml,
        provider_name: :provider_name,
        icon_path: :icon_path,
        idp_cert_fingerprint: :idp_cert_fingerprint,
        idp_cert: :idp_cert,
        certificate: :idp_cert,
        private_key: :idp_key,
        client_secret: :client_secret,
        issuer: :issuer,
        authn_context: :authn_context,
        assertion_consumer_service_url: :assertion_consumer_service_url,
        idp_sso_target_url: :idp_sso_target_url,
        idp_slo_target_url: :idp_slo_target_url,
        person_services_wsdl: :person_services_wsdl,
        person_services_cert: :person_services_cert,
        person_services_ca_cert: :person_services_ca_cert,
        person_services_key: :person_services_key,
        person_services_secret: :person_services_secret,
        person_services_proxy: :person_services_proxy,
        person_services_fallback_rrn: :person_services_fallback_rrn
      )
    )
  end

  if omniauth_config[:csam].present?
    provider(
      OmniAuth::Strategies::EidCsam,
      setup: setup_provider_proc(
        :csam,
        provider_name: :provider_name,
        icon_path: :icon_path,
        idp_cert_fingerprint: :idp_cert_fingerprint,
        idp_cert: :idp_cert,
        certificate: :idp_cert,
        private_key: :idp_key,
        client_secret: :client_secret,
        issuer: :issuer,
        authn_context: :authn_context,
        assertion_consumer_service_url: :assertion_consumer_service_url,
        idp_sso_target_url: :idp_sso_target_url,
        idp_slo_target_url: :idp_slo_target_url,
        person_services_wsdl: :person_services_wsdl,
        person_services_cert: :person_services_cert,
        person_services_ca_cert: :person_services_ca_cert,
        person_services_key: :person_services_key,
        person_services_secret: :person_services_secret,
        person_services_proxy: :person_services_proxy,
        person_services_fallback_rrn: :person_services_fallback_rrn
      )
    )
  end
end

# frozen_string_literal: true

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.

# Devise failure app to randomly stall failed login attempts, to prevent timing attacks.
class RandomStalling < Devise::FailureApp
  def respond
    sleep rand * 5
    super
  end

  protected

  def i18n_options(options)
    options[:locale] =
      session[:user_locale] || Decidim::Organization.find_by(host: request.host).try(:default_locale) || :nl
    super
  end
end

::Devise.setup do |config|
  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  config.timeout_in = 30.minutes

  config.parent_controller = "ApplicationController"

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  config.paranoid = true
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
        enable_scope_mapping: :enable_scope_mapping,
        scope_mapping_level_id: :scope_mapping_level_id,
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
        enable_scope_mapping: :enable_scope_mapping,
        scope_mapping_level_id: :scope_mapping_level_id,
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

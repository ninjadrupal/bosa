# frozen_string_literal: true

require "active_support/concern"

module UpdateOrganizationFormExtend
  extend ActiveSupport::Concern

  included do
    jsonb_attribute :initiatives_settings, [
      [:allow_users_to_see_initiative_no_signature_option, Boolean],
      [:create_initiative_minimum_age, Integer],
      [:create_initiative_allowed_postal_codes, String],
      [:sign_initiative_minimum_age, Integer],
      [:sign_initiative_allowed_postal_codes, String]
    ]

    def map_model(model)
      self.secondary_hosts = model.secondary_hosts.join("\n")
      self.omniauth_settings = Hash[(model.omniauth_settings || []).map do |k, v|
        [k, Decidim::OmniauthProvider.value_defined?(v) ? Decidim::AttributeEncryptor.decrypt(v) : v]
      end]

      # decidim-initiatives_no_signature_allowed
      if model.initiatives_settings.blank? || model.initiatives_settings["allow_users_to_see_initiative_no_signature_option"].blank?
        self.initiatives_settings ||= {}
        self.initiatives_settings["allow_users_to_see_initiative_no_signature_option"] = true # default is `true`
      end

      if model.initiatives_settings.present?
        self.initiatives_settings["create_initiative_allowed_postal_codes"] = (model.initiatives_settings["create_initiative_allowed_postal_codes"] || []).join("\n")
        self.initiatives_settings["sign_initiative_allowed_postal_codes"] = (model.initiatives_settings["sign_initiative_allowed_postal_codes"] || []).join("\n")
      end

      # decidim-suggestions
      if model.suggestions_settings.present?
        self.suggestions_settings["create_suggestion_allowed_postal_codes"] = (model.suggestions_settings["create_suggestion_allowed_postal_codes"] || []).join("\n")
        self.suggestions_settings["sign_suggestion_allowed_postal_codes"] = (model.suggestions_settings["sign_suggestion_allowed_postal_codes"] || []).join("\n")
      end
    end

    def clean_initiatives_settings
      return if initiatives_settings.blank?

      initiatives_settings[:create_initiative_allowed_postal_codes] = clean_initiative_allowed_postal_codes(:create)
      initiatives_settings[:sign_initiative_allowed_postal_codes] = clean_initiative_allowed_postal_codes(:sign)

      initiatives_settings
    end

    def set_from
      return from_email if from_label.blank?

      "#{from_label} <#{from_email}>"
    end

    private

    def clean_initiative_allowed_postal_codes(action)
      postal_codes = initiatives_settings.dig("#{action}_initiative_allowed_postal_codes".to_sym)
      return [] if postal_codes.blank?
      postal_codes.split("\n").map(&:chomp).select(&:present?)
    end

  end
end

Decidim::System::UpdateOrganizationForm.send(:include, UpdateOrganizationFormExtend)

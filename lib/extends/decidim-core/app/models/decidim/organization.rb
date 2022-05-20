# frozen_string_literal: true

require "active_support/concern"

module OrganizationExtend
  extend ActiveSupport::Concern

  included do
    def translatable_locales
      available_locales & Decidim.config.translatable_locales
    end

    def initiatives_settings_allow_users_to_see_initiative_attachments?
      return if self.initiatives_settings.blank?
      self.initiatives_settings["allow_users_to_see_initiative_attachments"]
    end

    #
    # `action` is one of:
    # - create
    # - sign
    #
    def initiatives_settings_allow_to?(user, action)
      initiatives_settings_minimum_age_allow_to?(user, action) &&
        initiatives_settings_allowed_regions_allow_to?(user, action)
    end

    def initiatives_settings_minimum_age_allow_to?(user, action)
      return true if !user || user.admin?
      minimum_age = initiatives_settings_minimum_age(action)
      return true if minimum_age.blank?

      authorization = Decidim::Initiatives::UserAuthorizations.for(user).where(name: :csam).first
      return false if !authorization || authorization.metadata[:official_birth_date].blank?

      return false if (((Time.zone.now - authorization.metadata[:official_birth_date].in_time_zone) / 1.year.seconds).floor < minimum_age)

      true
    end

    def initiatives_settings_allowed_regions_allow_to?(user, action)
      return true if !user || user.admin?
      allowed_regions = initiatives_settings_allowed_regions(action)
      return true if allowed_regions.blank?
      region_codes = Decidim::Organization::INITIATIVES_SETTINGS_ALLOWED_REGIONS.slice(*allowed_regions).values.pluck(:municipalities).flatten.map { |m| m[:idM] }.uniq
      return true if region_codes.blank?

      authorization = Decidim::Initiatives::UserAuthorizations.for(user).where(name: :csam).first
      return false if !authorization || authorization.metadata[:postal_code].blank?

      return false unless region_codes.member?(authorization.metadata[:postal_code])

      true
    end

    def initiatives_settings_minimum_age(action)
      return if self.initiatives_settings.blank?
      self.initiatives_settings["#{action}_initiative_minimum_age"]
    end

    def initiatives_settings_allowed_regions(action)
      return if self.initiatives_settings.blank?
      (self.initiatives_settings["#{action}_initiative_allowed_regions"] || []).reject(&:empty?)
    end

    def initiatives_settings_hide_areas_filter?
      return if self.initiatives_settings.blank?
      self.initiatives_settings["hide_areas_filter"]
    end

    def initiatives_settings_hide_scopes_filter?
      return if self.initiatives_settings.blank?
      self.initiatives_settings["hide_scopes_filter"]
    end

    def basic_auth_enabled?
      self.basic_auth_username.present? || self.basic_auth_password.present?
    end

    # def omniauth_provider_settings(provider)
    #   var = Decidim::Organization.omniauth_provider_settings(provider)
    #   Rails.logger.info " TCO var: #{var}"
    #   var
    # end

    def omniauth_provider_settings(provider)
      Rails.logger.info " TCO check 1 with provider #{provider}"
      Rails.logger.info " TCO omniauth_provider_settings.size #{@omniauth_provider_settings.size}" if @omniauth_provider_settings
      @omniauth_provider_settings ||= Hash.new do |hash, provider_key|
        Rails.logger.info " TCO cache empty"
        hash[provider_key] = begin
          omniauth_settings.each_with_object({}) do |(key, value), provider_settings|
            next unless key.to_s.include?(provider_key.to_s)
            Rails.logger.info " TCO decryption"
            value = Decidim::AttributeEncryptor.decrypt(value) if Decidim::OmniauthProvider.value_defined?(value)
            setting_key = Decidim::OmniauthProvider.extract_setting_key(key, provider_key)
            provider_settings[setting_key] = value
          end
        end
      end
      @omniauth_provider_settings[provider]
      Rails.logger.info " TCO returns cached value #{@omniauth_provider_settings[provider]} for key #{provider}"
    end

  end
end

Decidim::Organization.send(:include, OrganizationExtend)

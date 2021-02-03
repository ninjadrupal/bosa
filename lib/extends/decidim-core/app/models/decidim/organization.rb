# frozen_string_literal: true

require "active_support/concern"

module OrganizationExtend
  extend ActiveSupport::Concern

  included do
    def translatable_locales
      available_locales & Decidim.config.translatable_locales
    end

    #
    # `action` is one of:
    # - create
    # - sign
    #
    def initiatives_settings_allow_to?(user, action)
      initiatives_settings_minimum_age_allow_to?(user, action) &&
        initiatives_settings_allowed_postal_codes_allow_to?(user, action)
    end

    def initiatives_settings_minimum_age_allow_to?(user, action)
      return true if !user || user.admin?
      return true if self.initiatives_settings.blank?
      minimum_age = self.initiatives_settings["#{action}_initiative_minimum_age"]
      return true if minimum_age.blank?

      authorization = Decidim::Initiatives::UserAuthorizations.for(user).first
      return false if !authorization || authorization.metadata[:official_birth_date].blank?

      return false if (((Time.zone.now - authorization.metadata[:official_birth_date].in_time_zone) / 1.year.seconds).floor < minimum_age)

      true
    end

    def initiatives_settings_allowed_postal_codes_allow_to?(user, action)
      return true if !user || user.admin?
      return true if self.initiatives_settings.blank?
      allowed_postal_codes = self.initiatives_settings["#{action}_initiative_allowed_postal_codes"]
      return true if allowed_postal_codes.blank?

      authorization = Decidim::Initiatives::UserAuthorizations.for(user).first
      return false if !authorization || authorization.metadata[:postal_code].blank?

      return false unless allowed_postal_codes.member?(authorization.metadata[:postal_code])

      true
    end

    def initiatives_settings_minimum_age(action)
      return if self.initiatives_settings.blank?
      self.initiatives_settings["#{action}_initiative_minimum_age"]
    end

  end
end

Decidim::Organization.send(:include, OrganizationExtend)

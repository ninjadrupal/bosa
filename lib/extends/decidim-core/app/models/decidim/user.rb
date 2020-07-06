# frozen_string_literal: true
require "active_support/concern"

module UserExtend
  extend ActiveSupport::Concern

  included do
    clear_validators!
    validates :name, presence: true, unless: -> { deleted? }
    validates :nickname, presence: true, unless: -> { deleted? || managed? }, length: { maximum: Decidim::User.nickname_max_length }
    validates :locale, inclusion: { in: :available_locales }, allow_blank: true
    validates :tos_agreement, acceptance: true, allow_nil: false, on: :create
    validates :tos_agreement, acceptance: true, if: :user_invited?
    validates :email, :nickname, uniqueness: { scope: :organization }, unless: -> { deleted? || managed? || nickname.blank? || email.blank? }

    validate :all_roles_are_valid

    # Overrides devise email required validation.
    def email_required?
      false
    end

    def tos_accepted?
      return true if managed
      return true if email.blank?
      return false if accepted_tos_version.nil?

      # For some reason, if we don't use `#to_i` here we get some
      # cases where the comparison returns false, but calling `#to_i` returns
      # the same number :/
      accepted_tos_version.to_i >= organization.tos_version.to_i
    end

    def after_confirmation
      return if skip_after_confirmation?
      return unless organization.send_welcome_notification?

      Decidim::EventsManager.publish(
        event: "decidim.events.core.welcome_notification",
        event_class: WelcomeNotificationEvent,
        resource: self,
        affected_users: [self]
      )
    end

    def skip_reconfirmation!
      @skip_after_confirmation = true
      @bypass_confirmation_postpone = true
    end

    def skip_after_confirmation?
      defined?(@skip_after_confirmation) && @skip_after_confirmation
    end
  end
end

Decidim::User.send(:include, UserExtend)

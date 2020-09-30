# frozen_string_literal: true

require "active_support/concern"

module InitiativesInitiativesMailerExtend
  extend ActiveSupport::Concern

  included do
    def notify_state_change(initiative, user)
      return if user.email.blank?

      @initiative = initiative
      @organization = initiative.organization

      with_user(user) do
        @subject = I18n.t(
          "decidim.initiatives.initiatives_mailer.status_change_for",
          title: translated_attribute(initiative.title)
        )

        @body = I18n.t(
          "decidim.initiatives.initiatives_mailer.status_change_body_for",
          title: translated_attribute(initiative.title),
          state: I18n.t(initiative.state, scope: "decidim.initiatives.admin_states")
        )

        @link = initiative_url(initiative, host: @organization.host)

        mail(to: "#{user.name} <#{user.email}>", subject: @subject)
      end
    end

    def notify_validating_request(initiative, user)
      return if user.email.blank?

      @initiative = initiative
      @organization = initiative.organization
      @link = decidim_admin_initiatives.edit_initiative_url(initiative, host: @organization.host)

      with_user(user) do
        @subject = I18n.t(
          "decidim.initiatives.initiatives_mailer.technical_validation_for",
          title: translated_attribute(initiative.title)
        )
        @body = I18n.t(
          "decidim.initiatives.initiatives_mailer.technical_validation_body_for",
          title: translated_attribute(initiative.title)
        )

        mail(to: "#{user.name} <#{user.email}>", subject: @subject)
      end
    end

    def notify_progress(initiative, user)
      return if user.email.blank?

      @initiative = initiative
      @organization = initiative.organization
      @link = initiative_url(initiative, host: @organization.host)

      with_user(user) do
        @body = I18n.t(
          "decidim.initiatives.initiatives_mailer.progress_report_body_for",
          title: translated_attribute(initiative.title),
          percentage: initiative.percentage
        )

        @subject = I18n.t(
          "decidim.initiatives.initiatives_mailer.progress_report_for",
          title: translated_attribute(initiative.title),
          percentage: initiative.percentage
        )

        mail(to: "#{user.name} <#{user.email}>", subject: @subject)
      end
    end
  end
end

Decidim::Initiatives::InitiativesMailer.send(:include, InitiativesInitiativesMailerExtend)

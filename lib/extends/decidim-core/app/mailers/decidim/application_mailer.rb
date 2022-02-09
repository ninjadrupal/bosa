# frozen_string_literal: true

require "active_support/concern"

module ApplicationMailerExtend
  extend ActiveSupport::Concern

  included do

    private

    def set_smtp
      return if @organization.nil? || @organization.smtp_settings.blank?

      mail.from = @organization.smtp_settings["from"].presence || mail.from
      mail.reply_to = mail.reply_to || @organization.smtp_settings["from_email"].presence || Decidim.config.mailer_reply
      mail.delivery_method.settings.merge!(
        address: @organization.smtp_settings["address"],
        port: @organization.smtp_settings["port"],
        user_name: @organization.smtp_settings["user_name"],
        password: Decidim::AttributeEncryptor.decrypt(@organization.smtp_settings["encrypted_password"])
      ) { |_k, o, v| v.presence || o }.reject! { |_k, v| v.blank? }
    end
  end
end

Decidim::ApplicationMailer.send(:include, ApplicationMailerExtend)

# frozen_string_literal: true
require "active_support/concern"

module ApplicationMailerExtend
  extend ActiveSupport::Concern

  included do

    default reply_to: Decidim.config.mailer_reply || Decidim.config.mailer_sender

  end
end

Decidim::ApplicationMailer.send(:include, ApplicationMailerExtend)

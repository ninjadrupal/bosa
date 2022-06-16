# frozen_string_literal: true

require "active_support/concern"

module ConversationMailerExtend
  extend ActiveSupport::Concern

  included do

    private

    # rubocop:disable Metrics/ParameterLists
    def notification_mail(from:, to:, conversation:, action:, message: nil, third_party: nil)
      return if to.email.blank?

      with_user(to) do
        @organization = to.organization
        @conversation = conversation
        @sender = from
        @recipient = to
        @third_party = third_party
        @message = message
        @host = @organization.host

        subject = I18n.t(
          "conversation_mailer.#{action}.subject",
          scope: "decidim.messaging",
          sender: @sender.name,
          manager: @third_party&.name,
          group: @third_party&.name
        )

        mail(to: to.email, subject: subject)
      end
    end
    # rubocop:enable Metrics/ParameterLists

  end
end

Decidim::Messaging::ConversationMailer.send(:include, ConversationMailerExtend)

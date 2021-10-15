# frozen_string_literal: true

module Decidim
  module Surveys
    # This class serializes the answers given by a User for questionnaire so can be
    # exported to CSV, JSON or other formats.
    class UserAnswersSerializer < Decidim::Forms::UserAnswersSerializer

      def serialize
        @answers.each_with_index.inject({}) do |serialized, (answer, idx)|
          serialized.update(
            answer_translated_attribute_name(:id) => answer.id,
            answer_translated_attribute_name(:created_at) => answer.created_at.to_s(:db),
            answer_translated_attribute_name(:ip_hash) => answer.ip_hash,
            answer_translated_attribute_name(:user_status) => answer_translated_attribute_name(answer.decidim_user_id.present? ? "registered" : "unregistered"),
          )

          auth_data = socio_demographic_data(answer.user) || {}
          org = answer.questionnaire&.questionnaire_for&.organization
          serialized.update(
            sd_translated_attribute_name("category") => auth_data.present? ? sd_translated_attribute_value("categories", auth_data[:category]) : '',
            sd_translated_attribute_name("gender") => auth_data.present? ? sd_translated_attribute_value("genders", auth_data[:gender]) : '',
            sd_translated_attribute_name("age") => auth_data.dig(:age),
            sd_translated_attribute_name("study_level") => auth_data.dig(:study_level),
            sd_translated_attribute_name("scope_id") => auth_data.present? ? translated_attribute(org&.scopes&.find(auth_data.dig(:scope_id))&.name) : '',
          )

          serialized.update(
            "#{idx + 1}. #{translated_attribute(answer.question.body)}" => normalize_body(answer)
          )
        end
      end

      private

      def socio_demographic_data(user)
        return unless Decidim::Verifications.find_workflow_manifest(:socio_demographic_authorization_handler).present?
        return unless user.present?

        @socio_data ||= Decidim::Authorization.where(user: user, name: :socio_demographic_authorization_handler).where.not(granted_at: nil).first.try(:metadata)
      end

      def sd_translated_attribute_name(attribute)
        I18n.t(attribute, scope: "decidim.authorization_handlers.socio_demographic_authorization_handler.fields")
      end

      def sd_translated_attribute_value(node, attribute)
        return if attribute.blank?

        I18n.t(attribute, scope: "decidim.authorization_handlers.socio_demographic_authorization_handler.#{node}")
      end

    end
  end
end

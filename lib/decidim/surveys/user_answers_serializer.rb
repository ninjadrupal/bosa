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

          org = answer.questionnaire&.questionnaire_for&.organization
          [:socio_demographic_authorization_handler, :brucity_socio_demographic_authorization_handler].each do |handler_name|
            socio_data = socio_demographic_data(org, handler_name, answer.user) || {}
            serialized.update(socio_data) if socio_data.present?
          end
          serialized.update(
            "#{idx + 1}. #{translated_attribute(answer.question.body)}" => normalize_body(answer)
          )
        end
      end

      private

      def socio_demographic_data(org, handler_name, user)
        return if org.blank? || user.blank?

        socio_data = {}

        if org.available_authorization_handlers.include?(handler_name.to_s) && Decidim::Verifications.find_workflow_manifest(handler_name.to_sym).present?
          data = Decidim::Authorization.where(user: user, name: handler_name.to_sym).where.not(granted_at: nil).first.try(:metadata) || {}
          case (handler_name.to_sym)
            when :socio_demographic_authorization_handler
              socio_data.merge!(
                sd_translated_attribute_name(handler_name, "category") => data.present? ? sd_translated_attribute_value(handler_name, "categories", data[:category]) : '',
                sd_translated_attribute_name(handler_name, "gender") => data.present? ? sd_translated_attribute_value(handler_name, "genders", data[:gender]) : '',
                sd_translated_attribute_name(handler_name, "age") => data.dig(:age),
                sd_translated_attribute_name(handler_name, "study_level") => data.dig(:study_level),
                sd_translated_attribute_name(handler_name, "scope_id") => data.present? ? translated_attribute(org&.scopes&.find(data.dig(:scope_id))&.name) : '',
                sd_translated_attribute_name(handler_name, "postal_code") => data.dig(:postal_code)
              )
            when :brucity_socio_demographic_authorization_handler
              socio_data.merge!(
                sd_translated_attribute_name(handler_name, "residence") => data.present? ? sd_translated_attribute_value(handler_name, "residences", data[:residence]) : '',
                sd_translated_attribute_name(handler_name, "gender") => data.present? ? sd_translated_attribute_value(handler_name, "genders", data[:gender]) : '',
                sd_translated_attribute_name(handler_name, "date_of_birth") => data.dig(:date_of_birth)
              )
            else
              # nothing
          end
        end

        socio_data
      end

      def sd_translated_attribute_name(handler_name, attribute)
        I18n.t(attribute, scope: "decidim.authorization_handlers.#{handler_name}.fields")
      end

      def sd_translated_attribute_value(handler_name, node, attribute)
        return if attribute.blank?

        I18n.t(attribute, scope: "decidim.authorization_handlers.#{handler_name}.#{node}")
      end

    end
  end
end

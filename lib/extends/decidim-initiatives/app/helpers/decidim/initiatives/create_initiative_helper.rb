# frozen_string_literal: true

require "active_support/concern"

module CreateInitiativeHelperExtend
  extend ActiveSupport::Concern

  included do
    def signature_type_options(initiative_form)
      return all_signature_type_options unless initiative_form.signature_type_updatable?

      type = ::Decidim::InitiativesType.find(initiative_form.type_id)
      allowed_signatures = type.allowed_signature_types_for_initiatives

      if allowed_signatures == %w(online)
        online_signature_type_options
      elsif allowed_signatures == %w(offline)
        offline_signature_type_options
      elsif type.any_signature_type? # mixed
        any_signature_type_options
      else
        all_signature_type_options
      end
    end

    private

    def any_signature_type_options
      [
        [
          I18n.t(
            "any",
            scope: %w(activemodel attributes initiative signature_type_values)
          ), "any"
        ]
      ]
    end

  end
end

Decidim::Initiatives::CreateInitiativeHelper.send(:include, CreateInitiativeHelperExtend)

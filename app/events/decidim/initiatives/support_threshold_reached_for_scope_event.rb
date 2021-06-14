# frozen-string_literal: true

module Decidim
  module Initiatives
    class SupportThresholdReachedForScopeEvent < Decidim::Events::SimpleEvent
      i18n_attributes :scope_name

      def scope
        extra[:scope]
      end

      def scope_name
        translated_attribute(scope[:name])
      end
    end
  end
end

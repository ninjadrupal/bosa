# frozen_string_literal: true

require "active_support/concern"

module NeedsPermissionExtend
  extend ActiveSupport::Concern

  included do

    extend ActiveSupport::Concern

    included do
      def user_has_no_permission
        switch_locale do
          flash[:alert] = t("actions.unauthorized", scope: "decidim.core")
        end
        redirect_to(request.referer || user_has_no_permission_path)
      end
    end

  end
end

Decidim::NeedsPermission.send(:include, NeedsPermissionExtend)

# frozen_string_literal: true

require "active_support/concern"

module TermCustomizerAdminCachesControllerExtend
  extend ActiveSupport::Concern

  included do

    def clear
      enforce_permission_to :update, :organization

      Decidim::TermCustomizer.loader.clear_cache
      if current_organization&.id
        Rails.cache.delete_matched("decidim_term_customizer/organization_#{current_organization&.id}") rescue nil
      end

      flash[:notice] = I18n.t("caches.clear.success", scope: "decidim.term_customizer.admin")

      redirect_to translation_sets_path
    end

  end
end

Decidim::TermCustomizer::Admin::CachesController.send(:include, TermCustomizerAdminCachesControllerExtend)

# frozen_string_literal: true

require "active_support/concern"

module InitiativesApplicationHelperExtend
  extend ActiveSupport::Concern

  included do
    include Decidim::CheckBoxesTreeHelper

    def filter_sorts_values
      Decidim::CheckBoxesTreeHelper::TreeNode.new(
        Decidim::CheckBoxesTreeHelper::TreePoint.new("", t("decidim.initiatives.application_helper.filter_state_values.all")),
        [
          Decidim::CheckBoxesTreeHelper::TreePoint.new("published", t("decidim.initiatives.application_helper.filter_state_values.published")),
          Decidim::CheckBoxesTreeHelper::TreePoint.new("classified", t("decidim.initiatives.application_helper.filter_state_values.classified")),
          Decidim::CheckBoxesTreeHelper::TreePoint.new("examinated", t("decidim.initiatives.application_helper.filter_state_values.examinated")),
          Decidim::CheckBoxesTreeHelper::TreePoint.new("debatted", t("decidim.initiatives.application_helper.filter_state_values.debatted"))
        ]
      )
    end

    def filter_scopes_values
      Rails.cache.fetch(current_organization.scopes.cache_key) do
        main_scopes = current_organization.scopes.top_level

        scopes_values = main_scopes.includes(:scope_type, :children).flat_map do |scope|
          Decidim::CheckBoxesTreeHelper::TreeNode.new(
            Decidim::CheckBoxesTreeHelper::TreePoint.new(scope.id.to_s, translated_attribute(scope.name, current_organization)),
            scope_children_to_tree(scope)
          )
        end

        scopes_values.prepend(Decidim::CheckBoxesTreeHelper::TreePoint.new("global", t("decidim.scopes.global")))

        Decidim::CheckBoxesTreeHelper::TreeNode.new(
          Decidim::CheckBoxesTreeHelper::TreePoint.new("", t("decidim.initiatives.application_helper.filter_scope_values.all")),
          scopes_values
        )
      end
    end
  end
end

Decidim::Initiatives::ApplicationHelper.send(:include, InitiativesApplicationHelperExtend)

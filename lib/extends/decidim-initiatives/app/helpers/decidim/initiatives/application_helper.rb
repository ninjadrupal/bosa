# frozen_string_literal: true

require "active_support/concern"

module InitiativesApplicationHelperExtend
  extend ActiveSupport::Concern

  included do
    include Decidim::CheckBoxesTreeHelper

    def filter_states_values
      Decidim::CheckBoxesTreeHelper::TreeNode.new(
        Decidim::CheckBoxesTreeHelper::TreePoint.new("", t("decidim.initiatives.application_helper.filter_state_values.all")),
        [
          Decidim::CheckBoxesTreeHelper::TreePoint.new("open", t("decidim.initiatives.application_helper.filter_state_values.open")),
          Decidim::CheckBoxesTreeHelper::TreeNode.new(
            Decidim::CheckBoxesTreeHelper::TreePoint.new("closed", t("decidim.initiatives.application_helper.filter_state_values.closed")),
            [
              Decidim::CheckBoxesTreeHelper::TreePoint.new("accepted", t("decidim.initiatives.application_helper.filter_state_values.accepted")),
              Decidim::CheckBoxesTreeHelper::TreePoint.new("rejected", t("decidim.initiatives.application_helper.filter_state_values.rejected"))
            ]
          ),
          Decidim::CheckBoxesTreeHelper::TreeNode.new(
            Decidim::CheckBoxesTreeHelper::TreePoint.new("answered", t("decidim.initiatives.application_helper.filter_state_values.answered")),
            [
              Decidim::CheckBoxesTreeHelper::TreePoint.new("examinated", t("decidim.initiatives.application_helper.filter_state_values.examinated")),
              Decidim::CheckBoxesTreeHelper::TreePoint.new("debatted", t("decidim.initiatives.application_helper.filter_state_values.debatted")),
              Decidim::CheckBoxesTreeHelper::TreePoint.new("classified", t("decidim.initiatives.application_helper.filter_state_values.classified"))
            ]
          ),
        ]
      )
    end

  end
end

Decidim::Initiatives::ApplicationHelper.send(:include, InitiativesApplicationHelperExtend)

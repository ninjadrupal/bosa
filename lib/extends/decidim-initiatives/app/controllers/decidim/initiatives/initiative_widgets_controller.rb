# frozen_string_literal: true

require "active_support/concern"

module InitiativeWidgetsControllerExtend
  extend ActiveSupport::Concern

  included do
    def show
      return redirect_to "/404" unless visible?

      super
    end

    private

    def visible?
      current_initiative.published? || current_initiative.accepted? || current_initiative.rejected?
    end
  end
end

Decidim::Initiatives::InitiativeWidgetsController.send(:include, InitiativeWidgetsControllerExtend)

# frozen_string_literal: true
require "active_support/concern"

module SystemMenuHelperExtend
  extend ActiveSupport::Concern

  included do

    def main_menu
      @main_menu ||= ::Decidim::MenuPresenter.new(:system_menu, self, "main-nav")
    end

  end
end

Decidim::System::MenuHelper.send(:include, SystemMenuHelperExtend)

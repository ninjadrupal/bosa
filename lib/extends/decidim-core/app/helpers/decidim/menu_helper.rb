# frozen_string_literal: true

require "active_support/concern"

module MenuHelperExtend
  extend ActiveSupport::Concern

  included do
    def main_menu
      @main_menu ||= ::Decidim::MenuPresenter.new(
        :menu,
        self,
        "main-nav",
        element_class: "main-nav__link",
        active_class: "main-nav__link--active"
      )
    end

    def user_menu
      @user_menu ||= ::Decidim::InlineMenuPresenter.new(
        :user_menu,
        self,
        "user-nav",
        element_class: "tabs-title",
        active_class: "is-active"
      )
    end
  end
end

Decidim::MenuHelper.send(:include, MenuHelperExtend)

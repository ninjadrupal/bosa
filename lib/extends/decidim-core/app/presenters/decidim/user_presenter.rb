# frozen_string_literal: true

require "active_support/concern"

module UserPresenterExtend
  extend ActiveSupport::Concern

  included do

    def name
      ERB::Util.unwrapped_html_escape(__getobj__.name)
    end

    def officialization_text
      ERB::Util.unwrapped_html_escape(translated_attribute(officialized_as)).presence ||
        I18n.t("decidim.profiles.default_officialization_text_for_users")
    end

  end
end

Decidim::UserPresenter.send(:include, UserPresenterExtend)

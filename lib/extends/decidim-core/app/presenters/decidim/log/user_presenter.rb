# frozen_string_literal: true
require "active_support/concern"

module LogUserPresenterExtend
  extend ActiveSupport::Concern

  included do

    private
    def present_user_name
      extra["name"].html_safe || I18n.t("decidim.profile.deleted.name")
    end

    def user_path
      h.decidim.profile_path(present_user_nickname) if present_user_nickname.present?
    end

  end
end

Decidim::Log::UserPresenter.send(:include, LogUserPresenterExtend)

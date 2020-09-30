# frozen_string_literal: true

require "active_support/concern"

module DestroyAccountExtend
  extend ActiveSupport::Concern

  included do
    private

    def destroy_user_account!
      @user.name = ""
      @user.nickname = ""
      @user.email = ""
      @user.delete_reason = @form.delete_reason
      @user.admin = false if @user.admin?
      @user.deleted_at = Time.current
      @user.skip_reconfirmation!
      @user.remove_avatar!
      @user.save!
    end
  end
end

Decidim::DestroyAccount.send(:include, DestroyAccountExtend)

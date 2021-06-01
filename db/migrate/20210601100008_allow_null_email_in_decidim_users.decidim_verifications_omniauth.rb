# frozen_string_literal: true
# This migration comes from decidim_verifications_omniauth (originally 20210601093535)

class AllowNullEmailInDecidimUsers < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_users, :email, :string, null: true
  end
end

# frozen_string_literal: true

class AddBosaAppTypeToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :bosa_app_type, :string, default: 'default'
  end
end

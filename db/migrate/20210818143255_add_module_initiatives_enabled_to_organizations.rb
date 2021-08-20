# frozen_string_literal: true

class AddModuleInitiativesEnabledToOrganizations < ActiveRecord::Migration[5.2]
  def up
    add_column :decidim_organizations, :module_initiatives_enabled, :boolean
  end

  def down
    remove_column :decidim_organizations, :module_initiatives_enabled
  end
end

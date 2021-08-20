# frozen_string_literal: true
# This migration comes from decidim_suggestions (originally 20210818123321)

class AddModuleSuggestionsEnabledToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :module_suggestions_enabled, :boolean
  end
end

# frozen_string_literal: true

class CreateHasManyAreasTables < ActiveRecord::Migration[5.2]
  def up
    create_table :decidim_suggestions_areas do |t|
      t.references :decidim_suggestion, null: false, index: true
      t.references :decidim_area, null: false, index: true
      t.timestamps
    end
    Decidim::Suggestion.all.each do |s|
      next if s.decidim_area_id.blank?
      s.area_ids = [s.decidim_area_id]
      s.save
    end
  end

  def down
    drop_table :decidim_suggestions_areas
  end
end

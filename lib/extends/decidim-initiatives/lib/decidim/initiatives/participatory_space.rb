# frozen_string_literal: true

# Note: Initial :initiatives participatory space registration is already done on 'decidim-initiatives' gem initialization


# Define additional resource permissions for initiatives
manifest = Decidim.find_resource_manifest(:initiatives_type)
if manifest.present?
  manifest.actions = %w(create vote view_author_metadata)
end


# Update the `.exports` section for :initiatives participatory space to include initiatives into open data
manifest = Decidim.find_participatory_space_manifest(:initiatives)
if manifest.present? && manifest.export_manifests.present?
  export_manifest = manifest.export_manifests.find {|m| m.name == :initiatives}

  if export_manifest.present? && !export_manifest.include_in_open_data
    # export_manifest.collection do |initiative|
    #   Decidim::Initiative.where(id: initiative.id)
    # end
    export_manifest.collection do |initiative_ids|
      Decidim::Initiative.where(id: initiative_ids).includes(
        :author,
        :attachment_collections,
        :attachments,
        :components,
        :organization,
        :votes,
        scoped_type: :type
      )
    end

    export_manifest.include_in_open_data = true
  end
end

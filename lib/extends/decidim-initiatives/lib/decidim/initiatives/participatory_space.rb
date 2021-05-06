# frozen_string_literal: true

# Initial :initiatives participatory space registration is already done on 'decidim-initiatives' gem initialization
#
# Define additional resource permissions for initiatives
manifest = Decidim.find_resource_manifest(:initiatives_type)
if manifest.present?
  manifest.actions = %w(create vote view_author_metadata)
end

#
# Decidim.register_participatory_space(:initiatives) do |participatory_space|
#   ...
#   participatory_space.data_portable_entities = [
#     "Decidim::Initiative",
#     "Decidim::InitiativesVote"
#   ]
#   ...
# end

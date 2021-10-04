# frozen_string_literal: true

require './lib/decidim/surveys/user_answers_serializer'
require './lib/extends/decidim-core/lib/decidim/export_manifest'

manifest = Decidim.find_component_manifest(:surveys)
if manifest.present? && manifest.export_manifests.present?
  export_manifest = manifest.export_manifests.first
  export_manifest.serializer(Decidim::Surveys::UserAnswersSerializer, forced: true)
end
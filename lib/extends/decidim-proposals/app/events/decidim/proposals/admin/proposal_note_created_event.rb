# frozen-string_literal: true

require "active_support/concern"

module AdminProposalNoteCreatedEventExtend
  extend ActiveSupport::Concern

  included do

    def admin_proposal_info_url
      # decidim_admin_participatory_process_proposals.proposal_url(resource, resource.component.mounted_params)
      send(resource.component.mounted_admin_engine).proposal_url(resource, resource.component.mounted_params)
    end

  end
end

Decidim::Proposals::Admin::ProposalNoteCreatedEvent.send(:include, AdminProposalNoteCreatedEventExtend)

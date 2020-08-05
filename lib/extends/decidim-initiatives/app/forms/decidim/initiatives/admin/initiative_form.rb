# frozen_string_literal: true
require "active_support/concern"

module AdminInitiativeFormExtend
  extend ActiveSupport::Concern

  included do

    attribute :offline_votes, Hash

    validate :title, :title_max_length

    def map_model(model)
      self.type_id = model.type.id
      self.decidim_scope_id = model.scope&.id
      self.offline_votes = model.offline_votes

      if offline_votes.empty?
        self.offline_votes = model.votable_initiative_type_scopes.each_with_object({}) do |initiative_scope_type, all_votes|
          all_votes[initiative_scope_type.decidim_scopes_id || "global"] = [0, initiative_scope_type.scope_name]
        end
      else
        offline_votes.delete("total")
        self.offline_votes = offline_votes.each_with_object({}) do |(decidim_scope_id, votes), all_votes|
          scope_name = model.votable_initiative_type_scopes.find do |initiative_scope_type|
            initiative_scope_type.global_scope? && decidim_scope_id == "global" ||
              initiative_scope_type.decidim_scopes_id == decidim_scope_id.to_i
          end&.scope_name

          all_votes[decidim_scope_id || "global"] = [votes, scope_name]
        end
      end
    end

    # def signature_type_updatable?
    #   @signature_type_updatable ||= begin
    #                                   state ||= context.initiative.state
    #                                   state == "validating" && context.current_user.admin?
    #                                 end
    # end

    def title_max_length
      title.each do |locale, value|
        if value.length > 150
          errors.add("title_#{locale}".to_s, :too_long, { count: 150 })
        end
      end
    end

    def scoped_type_id
      return unless type && decidim_scope_id

      type.scopes.find_by(decidim_scopes_id: decidim_scope_id.presence).id
    end

  end
end

Decidim::Initiatives::Admin::InitiativeForm.send(:include, AdminInitiativeFormExtend)

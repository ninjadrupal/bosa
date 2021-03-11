# frozen_string_literal: true

require "active_support/concern"

module InitiativeSearchExtend
  extend ActiveSupport::Concern

  included do

    def search_state
      accepted = state.member?("accepted") ? query.accepted : nil
      rejected = state.member?("rejected") ? query.rejected : nil
      answered = state.member?("answered") ? query.answered : nil
      open = state.member?("open") ? query.open : nil
      closed = state.member?("closed") ? query.closed : nil
      examinated = state.member?("examinated") ? query.examinated : nil
      debatted = state.member?("debatted") ? query.debatted : nil
      classified = state.member?("classified") ? query.classified : nil

      query
        .where(id: accepted)
        .or(query.where(id: rejected))
        .or(query.where(id: answered))
        .or(query.where(id: open))
        .or(query.where(id: closed))
        .or(query.where(id: examinated))
        .or(query.where(id: debatted))
        .or(query.where(id: classified))
    end

    def search_area_id
      return query if area_ids.include?("all")

      query.
        joins("JOIN decidim_initiatives_areas ON decidim_initiatives.id = decidim_initiatives_areas.decidim_initiative_id").
        where(decidim_initiatives_areas: {decidim_area_id: area_ids}).
        group("decidim_initiatives.id")
    end

  end
end

Decidim::Initiatives::InitiativeSearch.send(:include, InitiativeSearchExtend)

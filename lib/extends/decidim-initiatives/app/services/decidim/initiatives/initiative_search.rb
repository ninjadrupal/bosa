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

  end
end

Decidim::Initiatives::InitiativeSearch.send(:include, InitiativeSearchExtend)

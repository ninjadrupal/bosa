# frozen_string_literal: true
require "active_support/concern"

module UnvoteInitiativeExtend
  extend ActiveSupport::Concern

  included do
    # Public: Initializes the command.
    #
    # initiative   - A Decidim::Initiative object.
    # current_user - The current user.
    def initialize(initiative, current_user)
      @initiative = initiative
      @current_user = current_user
    end

    private

    def destroy_initiative_vote
      Initiative.transaction do
        @initiative.votes.where(author: @current_user).destroy_all
      end
    end
  end
end

Decidim::Initiatives::UnvoteInitiative.send(:include, UnvoteInitiativeExtend)

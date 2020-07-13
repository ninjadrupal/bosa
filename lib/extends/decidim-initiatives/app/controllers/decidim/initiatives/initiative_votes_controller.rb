# frozen_string_literal: true
require "active_support/concern"

module InitiativeVotesControllerExtend
  extend ActiveSupport::Concern

  included do
    # POST /initiatives/:initiative_id/initiative_vote
    def create
      enforce_permission_to :vote, :initiative, initiative: current_initiative

      @form = form(Decidim::Initiatives::VoteForm).from_params(
        initiative: current_initiative,
        signer: current_user
      )

      Decidim::Initiatives::VoteInitiative.call(@form, current_user) do
        on(:ok) do
          current_initiative.reload
          render :update_buttons_and_counters
        end

        on(:invalid) do
          render json: {
            error: I18n.t("initiative_votes.create.error", scope: "decidim.initiatives")
          }, status: :unprocessable_entity
        end
      end
    end

    # DELETE /initiatives/:initiative_id/initiative_vote
    def destroy
      enforce_permission_to :unvote, :initiative, initiative: current_initiative

      Decidim::Initiatives::UnvoteInitiative.call(current_initiative, current_user) do
        on(:ok) do
          current_initiative.reload
          render :update_buttons_and_counters
        end
      end
    end
  end
end

Decidim::Initiatives::InitiativeVotesController.send(:include, InitiativeVotesControllerExtend)

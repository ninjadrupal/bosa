# frozen_string_literal: true

require "active_support/concern"

module AdminAnswersControllerExtend
  extend ActiveSupport::Concern

  included do
    # PUT /admin/initiatives/:id/answer
    def update
      enforce_permission_to :answer, :initiative, initiative: current_initiative

      params[:id] = params[:slug]
      @form = form(Decidim::Initiatives::Admin::InitiativeAnswerForm)
              .from_params(params, initiative: current_initiative)

      Decidim::Initiatives::Admin::UpdateInitiativeAnswer.call(current_initiative, @form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("initiatives.update.success", scope: "decidim.initiatives.admin")
          redirect_to initiatives_path
        end

        on(:invalid) do
          flash[:alert] = I18n.t("initiatives.update.error", scope: "decidim.initiatives.admin")
          redirect_to edit_initiative_answer_path
        end
      end
    end
  end
end

Decidim::Initiatives::Admin::AnswersController.send(:include, AdminAnswersControllerExtend)

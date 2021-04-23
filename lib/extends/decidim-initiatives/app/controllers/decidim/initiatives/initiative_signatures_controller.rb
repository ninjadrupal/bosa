# frozen_string_literal: true

require "active_support/concern"

module InitiativeSignaturesControllerExtend
  extend ActiveSupport::Concern

  included do
    helper_method :initiative_type, :extra_data_legal_information, :user_scopes

    # GET /initiatives/:initiative_id/initiative_signatures/:step
    def show
      group_id = params[:group_id] || (session[:initiative_vote_form] ||= {})["group_id"]
      if params[:id] == "finish"
        enforce_permission_to :vote, :initiative, initiative: current_initiative, group_id: group_id
      else
        enforce_permission_to :sign_initiative, :initiative, initiative: current_initiative, group_id: group_id, signature_has_steps: signature_has_steps?
      end
      send("#{step}_step", initiative_vote_form: session[:initiative_vote_form])
    end

    # POST /initiatives/:initiative_id/initiative_signatures
    def create
      group_id = params[:group_id] || session[:initiative_vote_form]&.dig("group_id")
      enforce_permission_to :vote, :initiative, initiative: current_initiative, group_id: group_id

      @form = form(Decidim::Initiatives::VoteForm)
              .from_params(
                initiative: current_initiative,
                signer: current_user,
                group_id: group_id
              )

      Decidim::Initiatives::VoteInitiative.call(@form) do
        on(:ok) do
          current_initiative.reload
          render :update_buttons_and_counters
        end

        on(:invalid) do
          render json: {
            error: I18n.t("create.error", scope: "decidim.initiatives.initiative_votes")
          }, status: :unprocessable_entity
        end
      end
    end

    private

    def fill_personal_data_step(_unused)
      @form = form(Decidim::Initiatives::VoteForm)
              .from_params(
                initiative: current_initiative,
                signer: current_user,
                group_id: params[:group_id]
              )

      session[:initiative_vote_form] = { group_id: @form.group_id }
      skip_step unless initiative_type.collect_user_extra_fields
      render_wizard
    end

    def finish_step(parameters)
      if parameters.has_key?(:initiatives_vote) || !fill_personal_data_step?
        build_vote_form(parameters)
      else
        check_session_personal_data
      end

      if sms_step?
        @confirmation_code_form = Decidim::Verifications::Sms::ConfirmationForm.from_params(parameters)

        Decidim::Initiatives::ValidateSmsCode.call(@confirmation_code_form, session_sms_code) do
          on(:ok) { clear_session_sms_code }

          on(:invalid) do
            flash[:alert] = I18n.t("sms_code.invalid", scope: "decidim.initiatives.initiative_votes")
            jump_to :sms_code
            render_wizard && return
          end
        end
      end

      Decidim::Initiatives::VoteInitiative.call(@vote_form) do
        on(:ok) do
          session[:initiative_vote_form] = {}
          redirect_to initiative_path(current_initiative) and return
        end

        on(:invalid) do |vote|
          logger.fatal "Failed creating signature: #{vote.errors.full_messages.join(", ")}" if vote
          flash[:alert] = I18n.t("create.invalid", scope: "decidim.initiatives.initiative_votes")
          jump_to previous_step
        end
      end

      render_wizard
    end

    def build_vote_form(parameters)
      @vote_form = form(Decidim::Initiatives::VoteForm).from_params(parameters).tap do |form|
        form.initiative = current_initiative
        form.signer = current_user
      end

      session[:initiative_vote_form] = session[:initiative_vote_form].merge(@vote_form.attributes_with_values)
    end

    def user_scopes
      @user_scopes ||= current_organization.scopes
    end
  end
end

Decidim::Initiatives::InitiativeSignaturesController.send(:include, InitiativeSignaturesControllerExtend)

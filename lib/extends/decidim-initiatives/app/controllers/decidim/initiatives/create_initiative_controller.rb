# frozen_string_literal: true
require "active_support/concern"

module CreateInitiativeControllerExtend
  extend ActiveSupport::Concern

  # Changes moved from decidim-module-initiatives_nosignature_allowed

  included do

    before_action :enforce_create_initiative_permission, only: [:show, :update]

    def show
      send("#{step}_step", initiative: session_initiative, type_id: params[:type_id])
    end

    private

    def previous_form_step(parameters)
      @form = build_form(Decidim::Initiatives::PreviousForm, parameters)

      if !single_initiative_type? && initiative_type_id.blank?
        redirect_to create_initiative_path(:select_initiative_type)
        return
      end

      render_wizard
    end

    def finish_step(_parameters)
      session[:initiative][:description] = nil
      render_wizard
    end

    def scopes
      @scopes ||= @form.available_scopes
    end

    def enforce_create_initiative_permission
      enforce_permission_to :create, :initiative
    end

  end
end

Decidim::Initiatives::CreateInitiativeController.send(:include, CreateInitiativeControllerExtend)

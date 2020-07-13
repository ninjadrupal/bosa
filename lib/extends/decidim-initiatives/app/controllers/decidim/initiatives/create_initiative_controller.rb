# frozen_string_literal: true
require "active_support/concern"

module CreateInitiativeControllerExtend
  extend ActiveSupport::Concern

  # Changes moved from decidim-module-initiatives_nosignature_allowed

  included do

    before_action :enforce_create_initiative_permission, only: [
      :select_initiative_type_step,
      :previous_form_step,
      :show_similar_initiatives_step,
      :fill_data_step,
      :finish_step
    ]

    def show
      send("#{step}_step", initiative: session_initiative, type_id: params[:type_id])
    end

    private

    def finish_step(_parameters)
      session[:initiative][:description] = nil
      render_wizard
    end

    def build_form(klass, parameters)
      @form = if single_initiative_type?
                form(klass).from_params(parameters.merge(type_id: current_organization_initiatives_type.first.id), extra_context)
              else
                form(klass).from_params(parameters, extra_context)
              end

      attributes = @form.attributes_with_values
      attributes[:description] = Decidim::ApplicationController.helpers.strip_tags(attributes[:description])
      session[:initiative] = session_initiative.merge(attributes)
      @form.valid? if params[:validate_form]

      @form
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

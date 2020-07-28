# frozen_string_literal: true
require "active_support/concern"

module InitiativesAdminEngineExtend
  extend ActiveSupport::Concern

  included do

    routes do
      resources :initiatives, only: [:index, :show, :edit, :update], param: :slug do
        collection do
          get :export
        end
      end
    end

  end
end

Decidim::Initiatives::AdminEngine.send(:include, InitiativesAdminEngineExtend)

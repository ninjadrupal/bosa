# frozen_string_literal: true

require "active_support/concern"

module SurveyHelperExtend
  extend ActiveSupport::Concern

  included do

    def authorize_action_path(handler_name)
      authorizations.status_for(handler_name).current_path(redirect_url: URI(request.original_url).path)
    end

  end
end

Decidim::Surveys::SurveyHelper.send(:include, SurveyHelperExtend)

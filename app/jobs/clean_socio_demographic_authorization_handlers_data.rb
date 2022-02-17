# frozen_string_literal: true

class CleanSocioDemographicAuthorizationHandlersData < ApplicationJob
  def perform
    DecidimAws::Application.load_tasks
    Rake::Task['db:decidim_authorizations:clean_socio_demographic_authorization_handlers_data'].invoke
  end
end

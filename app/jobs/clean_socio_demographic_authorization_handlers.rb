# frozen_string_literal: true

class CleanSocioDemographicAuthorizationHandlers < ApplicationJob
  def perform
    DecidimAws::Application.load_tasks
    Rake::Task['db:decidim_authorizations:clean_socio_demographic_authorization_handlers'].invoke
  end
end

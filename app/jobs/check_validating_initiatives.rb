# frozen_string_literal: true

class CheckValidatingInitiatives < ApplicationJob
  def perform
    DecidimAws::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["decidim_initiatives:check_validating"].reenable
    Rake::Task["decidim_initiatives:check_validating"].invoke
  end
end

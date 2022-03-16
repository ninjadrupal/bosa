# frozen_string_literal: true

class CheckValidatingSuggestions < ApplicationJob
  def perform
    DecidimAws::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["decidim_suggestions:check_validating"].reenable
    Rake::Task["decidim_suggestions:check_validating"].invoke
  end
end

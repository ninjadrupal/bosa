# frozen_string_literal: true

class CheckPublishedSuggestions < ApplicationJob
  def perform
    DecidimAws::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["decidim_suggestions:check_published"].reenable
    Rake::Task["decidim_suggestions:check_published"].invoke
  end
end

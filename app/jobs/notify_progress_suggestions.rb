# frozen_string_literal: true

class NotifyProgressSuggestions < ApplicationJob
  def perform
    DecidimAws::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["decidim_suggestions:notify_progress"].reenable
    Rake::Task["decidim_suggestions:notify_progress"].invoke
  end
end

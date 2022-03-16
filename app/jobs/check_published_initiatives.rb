# frozen_string_literal: true

class CheckPublishedInitiatives < ApplicationJob
  def perform
    DecidimAws::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["decidim_initiatives:check_published"].clear

    load Rails.root.join('lib', 'tasks', 'decidim_initiatives_extras.rake')
    Rake::Task['decidim_initiatives:check_published'].invoke
  end
end

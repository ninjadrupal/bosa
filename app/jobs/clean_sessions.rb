# frozen_string_literal: true

class CleanSessions < ApplicationJob
  def perform
    DecidimAws::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['db:sessions:trim'].reenable
    Rake::Task['db:sessions:trim'].invoke
  end
end

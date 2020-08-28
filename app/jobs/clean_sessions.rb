# frozen_string_literal: true

class CleanSessions < ApplicationJob
  def perform
    DecidimAws::Application.load_tasks
    Rake::Task['db:sessions:trim'].invoke
  end
end

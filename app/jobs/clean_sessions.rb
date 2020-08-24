# frozen_string_literal: true
require 'rake'

class CleanSessions < ApplicationJob

  def perform
    DecidimAws::Application.load_tasks
    Rake::Task["db:sessions:trim"].invoke
  end
end

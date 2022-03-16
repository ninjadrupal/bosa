# frozen_string_literal: true

class CleanSignInIps < ApplicationJob
  def perform
    DecidimAws::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['users:clean_sign_in_ips'].reenable
    Rake::Task['users:clean_sign_in_ips'].invoke
  end
end

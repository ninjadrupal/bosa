# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

Rake::Task['decidim_initiatives:check_published'].clear

load Rails.root.join('lib', 'tasks', 'decidim_initiatives_extras.rake')

require 'redmine'

Rails.application.config.to_prepare do
  TimeEntry.send(:include, RedmineTimeEntryEvents::Patches::TimeEntryPatch)
end

Redmine::Plugin.register :redmine_time_entry_events do
  name 'Redmine Time Entry Events Plugin'
  author 'DigitalWand'
  author_url 'http://digitalwand.ru'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  settings :default => {tries: 3}, :partial => 'settings/activity'
end

